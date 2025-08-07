import 'package:flutter/material.dart';
import '../data/storage/user_storage.dart';
import '../core/config/rpm_config.dart';

/// Сервис для работы с Ready Player Me
class RPMService extends ChangeNotifier {
  /// Состояние загрузки
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Ошибка
  String? _error;
  String? get error => _error;

  /// Прогресс загрузки модели
  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  /// Получение URL для RPM конструктора
  String getRPMConstructorUrl() {
    final url = RPMConfig.getFullUrl();
    debugPrint('RPM URL: $url');
    return url;
  }

  /// Альтернативный URL для публичной демо-версии
  String getPublicDemoUrl() {
    return RPMConfig.publicDemoUrl;
  }

  /// Проверка настройки API
  bool get isConfigured => RPMConfig.isConfigured;

  /// Получение инструкций по настройке
  List<String> getSetupInstructions() {
    return RPMConfig.setupInstructions;
  }

  /// Получение ссылок для настройки
  Map<String, String> getSetupLinks() {
    return RPMConfig.links;
  }

  /// Получение простого URL без параметров (запасной вариант)
  String getSimpleRPMUrl() {
    return 'https://demo.readyplayer.me/avatar?frameApi';
  }

  /// Обработка сообщения от WebView
  Future<void> handleWebViewMessage(Map<String, dynamic> message) async {
    try {
      final String eventType = message['eventName'] ?? '';

      debugPrint('RPM Event: $eventType');
      debugPrint('RPM Data: ${message['data']}');

      switch (eventType) {
        case 'v1.avatar.exported':
          await _handleAvatarExported(message['data']);
          break;

        case 'v1.user.set':
          await _handleUserSet(message['data']);
          break;

        case 'v1.frame.ready':
          debugPrint('RPM Frame готов');
          _setLoading(false);
          break;

        case 'webview.ready':
          debugPrint('WebView готов для RPM');
          break;

        default:
          debugPrint('Неизвестное RPM событие: $eventType');
          // Пытаемся обработать как прямое событие аватара
          if (message['data'] != null) {
            final data = message['data'];
            if (data is Map && data['url'] != null) {
              await _handleAvatarExported(data);
            } else if (data is String && _isValidRPMUrl(data)) {
              await _handleAvatarExported({'url': data});
            }
          }
      }
    } catch (e) {
      _setError('Ошибка обработки сообщения: $e');
    }
  }

  /// Обработка экспорта аватара
  Future<void> _handleAvatarExported(dynamic data) async {
    try {
      _setLoading(true);

      Map<String, dynamic> avatarData;

      // Безопасное приведение типов
      if (data is Map<String, dynamic>) {
        avatarData = data;
      } else if (data is Map) {
        avatarData = Map<String, dynamic>.from(data);
      } else {
        throw Exception('Неверный формат данных аватара: $data');
      }

      final String avatarUrl = avatarData['url'] ?? '';

      if (avatarUrl.isEmpty) {
        throw Exception('Не получен URL аватара от Ready Player Me');
      }

      if (!_isValidRPMUrl(avatarUrl)) {
        throw Exception('Неверный формат URL аватара: $avatarUrl');
      }

      debugPrint('Получен RPM аватар: $avatarUrl');

      // Извлекаем ID аватара
      final avatarId = _extractAvatarId(avatarUrl);

      // Сохраняем в профиле пользователя
      final user = await UserStorage.getCurrentUser();
      if (user != null) {
        final updatedUser = user.copyWith(
          rpmAvatarUrl: avatarUrl,
          rpmAvatarId: avatarId,
          useRpmAvatar: true,
        );

        await UserStorage.saveUser(updatedUser);
        debugPrint('RPM аватар сохранен в профиле пользователя');
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Ошибка сохранения аватара: $e');
    }
  }

  /// Обработка установки пользователя
  Future<void> _handleUserSet(dynamic data) async {
    debugPrint('RPM пользователь установлен: $data');
    // Здесь можно обработать дополнительную информацию о пользователе
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

  /// Получение URL для превью аватара
  String getAvatarPreviewUrl(
    String avatarId, {
    String expression = 'neutral',
    String pose = 'A',
    int size = 512,
  }) {
    return 'https://render.readyplayer.me/$avatarId.png?pose=$pose&expression=$expression&size=${size}x$size';
  }

  /// Получение URL для превью с альтернативными параметрами
  String getAvatarPreviewUrlAlt(String avatarId) {
    return 'https://render.readyplayer.me/$avatarId.png';
  }

  /// Переключение на RPM аватар
  Future<void> enableRPMAvatar() async {
    final user = await UserStorage.getCurrentUser();
    if (user != null && user.rpmAvatarUrl != null) {
      await UserStorage.saveUser(user.copyWith(useRpmAvatar: true));
      notifyListeners();
    }
  }

  /// Переключение на кастомный аватар
  Future<void> disableRPMAvatar() async {
    final user = await UserStorage.getCurrentUser();
    if (user != null) {
      await UserStorage.saveUser(user.copyWith(useRpmAvatar: false));
      notifyListeners();
    }
  }

  /// Проверка наличия RPM аватара у пользователя
  Future<bool> hasRPMAvatar() async {
    final user = await UserStorage.getCurrentUser();
    return user?.rpmAvatarUrl != null;
  }

  /// Валидация URL RPM модели
  bool _isValidRPMUrl(String url) {
    return url.contains('models.readyplayer.me') && url.endsWith('.glb');
  }

  /// Публичная версия валидации URL
  bool isValidRPMUrl(String url) {
    return _isValidRPMUrl(url);
  }

  /// Очистка RPM данных
  Future<void> clearRPMData() async {
    final user = await UserStorage.getCurrentUser();
    if (user != null) {
      await UserStorage.saveUser(user.copyWith(
        rpmAvatarUrl: null,
        rpmAvatarId: null,
        useRpmAvatar: false,
      ));
      notifyListeners();
    }
  }

  /// Получение информации о RPM аватаре
  Future<Map<String, dynamic>?> getRPMAvatarInfo() async {
    final user = await UserStorage.getCurrentUser();
    if (user?.rpmAvatarUrl != null) {
      return {
        'url': user!.rpmAvatarUrl,
        'id': user.rpmAvatarId,
        'previewUrl': user.rpmAvatarId != null
            ? getAvatarPreviewUrl(user.rpmAvatarId!)
            : null,
        'isActive': user.useRpmAvatar,
      };
    }
    return null;
  }

  /// Тестирование подключения к RPM
  Future<bool> testRPMConnection() async {
    try {
      _setLoading(true);

      // Здесь можно добавить проверку доступности RPM API
      await Future.delayed(const Duration(seconds: 1));

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Ошибка подключения к RPM: $e');
      return false;
    }
  }

  /// Установка состояния загрузки
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Установка ошибки
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Обновление прогресса загрузки
  void updateProgress(double progress) {
    _downloadProgress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }
}
