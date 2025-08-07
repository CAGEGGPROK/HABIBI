import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../services/rpm_service.dart';
import '../../data/models/user_model.dart';
import '../../data/storage/user_storage.dart';
import '../../services/stats_service.dart';
import '../widgets/webview_helper.dart';

/// Экран создания аватара Ready Player Me с WebView
class RPMCreatorScreen extends StatefulWidget {
  const RPMCreatorScreen({super.key});

  @override
  State<RPMCreatorScreen> createState() => _RPMCreatorScreenState();
}

class _RPMCreatorScreenState extends State<RPMCreatorScreen> {
  late WebViewController _webViewController;
  bool _isPageLoaded = false;
  bool _isCreatingAvatar = false;
  String? _errorMessage;
  String _userName = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// Инициализация WebView
  void _initializeWebView() async {
    try {
      // Проверяем поддержку WebView
      final isSupported = await WebViewHelper.isWebViewSupported();
      if (!isSupported) {
        setState(() {
          _errorMessage = 'WebView не поддерживается на этом устройстве';
        });
        return;
      }

      final rpmService = context.read<RPMService>();

      // Выбираем URL в зависимости от конфигурации
      String rpmUrl;
      if (rpmService.isConfigured) {
        rpmUrl = rpmService.getRPMConstructorUrl();
        debugPrint('Используем настроенный RPM URL');
      } else {
        rpmUrl = rpmService.getPublicDemoUrl();
        debugPrint('Используем публичный демо URL');
      }

      // Используем helper для создания контроллера
      _webViewController = await WebViewHelper.createRPMWebViewController(
        navigationDelegate: NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Страница начала загружаться: $url');
            if (mounted) {
              setState(() {
                _isPageLoaded = false;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (String url) {
            debugPrint('Страница загружена: $url');
            if (mounted) {
              setState(() {
                _isPageLoaded = true;
              });
              // Задержка перед инжектом JS для уверенности что страница готова
              Future.delayed(const Duration(milliseconds: 1000), () {
                _injectJavaScript();
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            final errorMessage = WebViewHelper.getErrorMessage(error);
            debugPrint('Ошибка загрузки: $errorMessage');
            if (mounted) {
              setState(() {
                _errorMessage = errorMessage;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Запрос навигации: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('Получено сообщение от WebView: ${message.message}');
          _handleRPMMessage(message.message);
        },
      );

      // Загружаем URL после инициализации
      try {
        await _webViewController.loadRequest(Uri.parse(rpmUrl));
        debugPrint('URL успешно загружен: $rpmUrl');
      } catch (e) {
        debugPrint('Ошибка загрузки URL: $e');
        setState(() {
          _errorMessage = 'Ошибка загрузки Ready Player Me: $e';
        });
        return;
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Ошибка инициализации WebView: $e');
      setState(() {
        _errorMessage = 'Ошибка инициализации WebView: $e';
      });
    }
  }

  /// Загрузка URL Ready Player Me
  void _loadRPMUrl(String url) {
    try {
      debugPrint('Загружаем RPM URL: $url');

      // Если WebView еще не инициализирован, инициализируем его
      if (!_isInitialized) {
        _initializeWebView();
        return;
      }

      _webViewController.loadRequest(Uri.parse(url));
    } catch (e) {
      debugPrint('Ошибка загрузки URL: $e');
      setState(() {
        _errorMessage = 'Ошибка загрузки URL: $e';
      });
    }
  }

  /// Внедрение JavaScript для обработки событий RPM
  void _injectJavaScript() {
    try {
      final jsCode = WebViewHelper.getRPMIntegrationScript();
      _webViewController.runJavaScript(jsCode);
      debugPrint('JavaScript успешно внедрен');
    } catch (e) {
      debugPrint('Ошибка внедрения JavaScript: $e');
    }
  }

  /// Обработка сообщений от RPM
  void _handleRPMMessage(String message) async {
    try {
      final data = jsonDecode(message);
      final eventName = data['eventName'] as String?;

      debugPrint('RPM Event: $eventName');
      debugPrint('RPM Data: ${data['data']}');

      switch (eventName) {
        case 'v1.avatar.exported':
          await _handleAvatarExported(data['data']);
          break;

        case 'v1.user.set':
          await _handleUserSet(data['data']);
          break;

        case 'webview.ready':
          debugPrint('WebView готов к работе с RPM');
          break;

        case 'postMessage':
          _handlePostMessage(data['data']);
          break;

        case 'error':
          _handleError(data['data']['error'] ?? 'Неизвестная ошибка');
          break;

        default:
          debugPrint('Неизвестное RPM событие: $eventName');
          // Пытаемся обработать как прямое событие аватара
          if (data['data'] != null && data['data']['url'] != null) {
            await _handleAvatarExported(data['data']);
          }
      }
    } catch (e) {
      debugPrint('Ошибка парсинга RPM сообщения: $e');
      // Пытаемся обработать как прямую строку URL
      if (message.contains('models.readyplayer.me') &&
          message.contains('.glb')) {
        await _handleAvatarExported({'url': message});
      } else {
        _handleError('Ошибка обработки данных от RPM: $e');
      }
    }
  }

  /// Обработка postMessage событий
  void _handlePostMessage(dynamic data) {
    debugPrint('PostMessage data: $data');

    // Проверяем, есть ли URL аватара в данных
    if (data is Map && data['url'] != null) {
      _handleAvatarExported(data);
    } else if (data is String && data.contains('models.readyplayer.me')) {
      _handleAvatarExported({'url': data});
    }
  }

  /// Обработка экспорта аватара
  Future<void> _handleAvatarExported(dynamic data) async {
    if (!mounted) return;

    setState(() {
      _isCreatingAvatar = true;
    });

    try {
      String? avatarUrl;

      if (data is Map) {
        avatarUrl = data['url'] as String?;
      } else if (data is String) {
        avatarUrl = data;
      }

      if (avatarUrl == null || avatarUrl.isEmpty) {
        throw Exception('Не получен URL аватара от Ready Player Me');
      }

      // Проверяем, что URL валидный
      if (!avatarUrl.contains('models.readyplayer.me') ||
          !avatarUrl.endsWith('.glb')) {
        throw Exception('Неверный формат URL аватара: $avatarUrl');
      }

      debugPrint('Получен RPM аватар: $avatarUrl');

      // Создаем пользователя с RPM аватаром
      await _createUserWithRPMAvatar(avatarUrl);

      if (mounted) {
        setState(() {
          _isCreatingAvatar = false;
        });

        // Показываем успешное создание и переходим
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('Ошибка сохранения аватара: $e');
      if (mounted) {
        setState(() {
          _isCreatingAvatar = false;
        });
        _handleError('Ошибка сохранения аватара: $e');
      }
    }
  }

  /// Обработка установки пользователя
  Future<void> _handleUserSet(dynamic data) async {
    debugPrint('RPM пользователь установлен: $data');
    // Здесь можно получить дополнительную информацию о пользователе
  }

  /// Создание пользователя с RPM аватаром
  Future<void> _createUserWithRPMAvatar(String avatarUrl) async {
    try {
      // Извлекаем ID аватара из URL
      final avatarId = _extractAvatarId(avatarUrl);

      // Используем имя из поля или дефолтное
      final userName = _userName.isNotEmpty ? _userName : 'RPM Игрок';

      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: userName,
        createdAt: DateTime.now(),
        rpmAvatarUrl: avatarUrl,
        rpmAvatarId: avatarId,
        useRpmAvatar: true,
      );

      await UserStorage.saveUser(user);
      debugPrint('Пользователь с RPM аватаром сохранен');

      // Инициализируем статистику
      if (mounted) {
        final statsService = context.read<StatsService>();
        await statsService.initializeStats(user.id);
        debugPrint('Статистика инициализирована');
      }

      // Обновляем RPM сервис
      final rpmService = context.read<RPMService>();
      await rpmService.handleWebViewMessage({
        'eventName': 'v1.avatar.exported',
        'data': {'url': avatarUrl}
      });
    } catch (e) {
      debugPrint('Ошибка создания пользователя: $e');
      rethrow;
    }
  }

  /// Извлечение ID аватара из URL
  String _extractAvatarId(String url) {
    try {
      final uri = Uri.parse(url);
      final fileName = uri.pathSegments.last;
      final id = fileName.replaceAll('.glb', '');
      debugPrint('Извлечен ID аватара: $id');
      return id;
    } catch (e) {
      debugPrint('Ошибка извлечения ID: $e');
      return 'avatar-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Обработка ошибок
  void _handleError(String error) {
    debugPrint('RPM Error: $error');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Закрыть',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// Показ диалога успешного создания
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Аватар создан!'),
          ],
        ),
        content: const Text(
          'Ваш 3D аватар успешно создан с помощью Ready Player Me.\nДобро пожаловать в Habit RPG!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Начать игру'),
          ),
        ],
      ),
    );
  }

  /// Показ диалога ввода имени
  void _showNameDialog() {
    final nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Имя персонажа'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Введите имя персонажа',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = nameController.text.trim();
              });
              Navigator.pop(context);

              // Показываем подтверждение
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Имя установлено: ${_userName.isEmpty ? "RPM Игрок" : _userName}'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  /// Перезагрузка страницы
  void _reloadPage() {
    if (_isInitialized) {
      setState(() {
        _errorMessage = null;
        _isPageLoaded = false;
      });
      final rpmService = context.read<RPMService>();
      _loadRPMUrl(rpmService.getRPMConstructorUrl());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ready Player Me'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.splash);
          },
        ),
        actions: [
          // Кнопка для ввода имени
          IconButton(
            icon: Icon(
              _userName.isNotEmpty ? Icons.person : Icons.person_outline,
              color: _userName.isNotEmpty ? Colors.amber : Colors.white,
            ),
            onPressed: _showNameDialog,
            tooltip: 'Имя персонажа',
          ),
          // Кнопка перезагрузки
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadPage,
            tooltip: 'Перезагрузить',
          ),
          // Кнопка справки
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Справка',
          ),
        ],
      ),
      body: Consumer<RPMService>(
        builder: (context, rpmService, child) {
          return Stack(
            children: [
              // WebView с Ready Player Me
              if (_errorMessage == null && _isInitialized) ...[
                WebViewWidget(controller: _webViewController),

                // Индикатор загрузки страницы
                if (!_isPageLoaded)
                  Container(
                    color: AppColors.background,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Загружаем Ready Player Me...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Это может занять несколько секунд',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ] else ...[
                // Экран ошибки
                _buildErrorScreen(),
              ],

              // Индикатор создания аватара
              if (_isCreatingAvatar)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Сохраняем ваш аватар...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userName.isNotEmpty
                                  ? 'Персонаж: $_userName'
                                  : 'Почти готово!',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      // Кнопка альтернативы
      floatingActionButton: _isPageLoaded && !_isCreatingAvatar
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.createAvatar);
              },
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.palette),
              label: const Text('Встроенный редактор'),
            )
          : null,
    );
  }

  /// Экран ошибки
  Widget _buildErrorScreen() {
    final rpmService = context.read<RPMService>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.api_rounded,
                size: 64,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              const Text(
                'Настройка Ready Player Me',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ??
                    'Для работы с Ready Player Me необходима настройка API',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Инструкции по настройке
              if (!rpmService.isConfigured) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Инструкция по настройке:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...rpmService.getSetupInstructions().map(
                            (instruction) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                instruction,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                      const SizedBox(height: 12),
                      const Text(
                        '📂 Файл конфигурации: lib/core/config/rpm_config.dart',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Кнопка для пробной версии
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _tryPublicDemo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Попробовать демо-версию'),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Кнопка повтора
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                    _initializeWebView();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Попробовать снова'),
                ),
              ),
              const SizedBox(height: 16),

              // Альтернативный вариант
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.createAvatar);
                },
                child: const Text('Использовать встроенный редактор'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Попробовать публичную демо-версию
  void _tryPublicDemo() {
    setState(() {
      _errorMessage = null;
      _isPageLoaded = false;
      _isInitialized = false;
    });

    // Показываем сообщение о загрузке демо
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Загружаем демо-версию Ready Player Me...'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );

    // Перезапускаем WebView с демо URL
    _initializeWebView();
  }

  /// Диалог справки
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Как создать аватар'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎯 Пошаговая инструкция:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '1. Выберите пол персонажа\n'
                '2. Настройте внешность:\n'
                '   • Форму лица и цвет кожи\n'
                '   • Прическу и цвет волос\n'
                '   • Черты лица и глаза\n'
                '   • Одежду и аксессуары\n'
                '3. Нажмите "Next" или "Done"\n'
                '4. Дождитесь сохранения аватара',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 16),
              Text(
                '💡 Советы:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Установите имя персонажа через кнопку профиля\n'
                '• Если страница не загружается - нажмите обновить\n'
                '• Аватар автоматически сохранится в игре',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
