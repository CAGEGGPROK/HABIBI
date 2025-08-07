import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../services/rpm_service.dart';
import '../../data/models/user_model.dart';
import '../../data/storage/user_storage.dart';
import '../../services/stats_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// Инициализация WebView
  void _initializeWebView() {
    final rpmService = context.read<RPMService>();
    final rpmUrl = rpmService.getRPMConstructorUrl();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isPageLoaded = false;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isPageLoaded = true;
            });
            _injectJavaScript();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = 'Ошибка загрузки: ${error.description}';
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterApp',
        onMessageReceived: (JavaScriptMessage message) {
          _handleRPMMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse(rpmUrl));
  }

  /// Внедрение JavaScript для обработки событий RPM
  void _injectJavaScript() {
    const jsCode = '''
      (function() {
        console.log('Flutter RPM Integration: Injecting JavaScript');
        
        // Функция для отправки сообщений в Flutter
        function sendToFlutter(data) {
          if (window.FlutterApp && window.FlutterApp.postMessage) {
            window.FlutterApp.postMessage(JSON.stringify(data));
          }
        }
        
        // Обработчик событий от Ready Player Me
        window.addEventListener('message', function(event) {
          console.log('RPM Event received:', event);
          
          if (!event.data) return;
          
          try {
            let data = event.data;
            if (typeof data === 'string') {
              data = JSON.parse(data);
            }
            
            console.log('Processed RPM data:', data);
            
            // Отправляем все события в Flutter
            sendToFlutter({
              eventName: data.eventName || 'unknown',
              data: data.data || data,
              source: 'rpm'
            });
            
          } catch (e) {
            console.error('Error processing RPM event:', e);
            sendToFlutter({
              eventName: 'error',
              data: { error: e.message },
              source: 'rpm'
            });
          }
        });
        
        // Уведомляем Flutter о готовности
        sendToFlutter({
          eventName: 'webview.ready',
          data: { status: 'ready' },
          source: 'flutter'
        });
        
        console.log('Flutter RPM Integration: JavaScript injection complete');
      })();
    ''';

    _webViewController.runJavaScript(jsCode);
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

        case 'error':
          _handleError(data['data']['error'] ?? 'Неизвестная ошибка');
          break;

        default:
          debugPrint('Неизвестное RPM событие: $eventName');
      }
    } catch (e) {
      debugPrint('Ошибка парсинга RPM сообщения: $e');
      _handleError('Ошибка обработки данных от RPM');
    }
  }

  /// Обработка экспорта аватара
  Future<void> _handleAvatarExported(dynamic data) async {
    setState(() {
      _isCreatingAvatar = true;
    });

    try {
      final avatarUrl = data['url'] as String?;

      if (avatarUrl == null || avatarUrl.isEmpty) {
        throw Exception('Не получен URL аватара от Ready Player Me');
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

    // Инициализируем статистику
    if (mounted) {
      final statsService = context.read<StatsService>();
      await statsService.initializeStats(user.id);
    }

    // Обновляем RPM сервис
    final rpmService = context.read<RPMService>();
    await rpmService.handleWebViewMessage({
      'eventName': 'v1.avatar.exported',
      'data': {'url': avatarUrl}
    });
  }

  /// Извлечение ID аватара из URL
  String _extractAvatarId(String url) {
    try {
      final uri = Uri.parse(url);
      final fileName = uri.pathSegments.last;
      return fileName.replaceAll('.glb', '');
    } catch (e) {
      return 'avatar-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Обработка ошибок
  void _handleError(String error) {
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
    final nameController = TextEditingController();

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
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
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
            icon: const Icon(Icons.person_outline),
            onPressed: _showNameDialog,
            tooltip: 'Имя персонажа',
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
              if (_errorMessage == null) ...[
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ошибка загрузки Ready Player Me',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Неизвестная ошибка',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializeWebView();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.createAvatar);
              },
              child: const Text('Использовать встроенный редактор'),
            ),
          ],
        ),
      ),
    );
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
                '1. Выберите пол персонажа\n'
                '2. Настройте внешность:\n'
                '   • Форму лица и цвет кожи\n'
                '   • Прическу и цвет волос\n'
                '   • Черты лица\n'
                '   • Одежду и аксессуары\n'
                '3. Нажмите "Next" или "Done"\n'
                '4. Дождитесь сохранения аватара',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'После создания аватар автоматически сохранится в вашем профиле.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
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
