import 'package:flutter/material.dart';
import '../data/storage/user_storage.dart';

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

  /// Конфигурация Ready Player Me
  static const String subdomain = 'demo'; // Можно заменить на свой поддомен
  static const Map<String, String> rpmConfig = {
    'bodyType': 'fullbody',
    'quickStart': 'false',
    'clearCache': 'true',
    'language': 'ru',
  };

  /// Получение URL для RPM конструктора
  String getRPMConstructorUrl() {
    final baseUrl = 'https://$subdomain.readyplayer.me/avatar';
    final params = <String>[];

    // Добавляем frameApi для интеграции
    params.add('frameApi');

    // Добавляем конфигурацию
    rpmConfig.forEach((key, value) {
      params.add('$key=$value');
    });

    final fullUrl = '$baseUrl?${params.join('&')}';
    debugPrint('RPM URL: $fullUrl');

    return fullUrl;
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
          break;

        case 'webview.ready':
          debugPrint('WebView готов для RPM');
          break;

        default:
          debugPrint('Неизвестное RPM событие: $eventType');
      }
    } catch (e) {
      _setError('Ошибка обработки сообщения: $e');
    }
  }

  /// Обработка экспорта аватара
  Future<void> _handleAvatarExported(Map<String, dynamic> data) async {
    try {
      _setLoading(true);

      final String avatarUrl = data['url'] ?? '';

      if (avatarUrl.isEmpty) {
        throw Exception('Не получен URL аватара от Ready Player Me');
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
  Future<void> _handleUserSet(Map<String, dynamic> data) async {
    debugPrint('RPM пользователь установлен: $data');
    // Здесь можно обработать дополнительную информацию о пользователе
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

  /// Получение URL для превью аватара
  String getAvatarPreviewUrl(
    String avatarId, {
    String expression = 'neutral',
    String pose = 'A',
    int size = 512,
  }) {
    return 'https://render.readyplayer.me/$avatarId.png?pose=$pose&expression=$expression&size=${size}x$size';
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
  bool isValidRPMUrl(String url) {
    return url.contains('models.readyplayer.me') && url.endsWith('.glb');
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
}
