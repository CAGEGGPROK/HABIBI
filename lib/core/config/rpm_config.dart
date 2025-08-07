/// Конфигурация Ready Player Me API
///
/// Для настройки:
/// 1. Зарегистрируйтесь на https://readyplayer.me/
/// 2. Создайте приложение в https://studio.readyplayer.me/
/// 3. Получите ваш поддомен и App ID
/// 4. Замените значения ниже
/// 5. Перезапустите приложение

class RPMConfig {
  /// Ваш поддомен Ready Player Me
  /// Пример: если ваш URL https://myapp.readyplayer.me, то subdomain = 'myapp'
  static const String subdomain = 'demo';

  /// Ваш App ID из Ready Player Me Studio
  /// Получить можно в https://studio.readyplayer.me/
  static const String appId = 'sk_live_RZKH92O2z4Z1G80QVHowaiJ9_CBS6NdQcCEV';

  /// Дополнительные параметры конфигурации
  static const Map<String, String> defaultParams = {
    'bodyType': 'fullbody',
    'quickStart': 'false',
    'clearCache': 'true',
    'language': 'en',
  };

  /// Проверка настройки
  static bool get isConfigured => subdomain != 'demo' && appId != 'your-app-id';

  /// Получение базового URL
  static String get baseUrl => 'https://$subdomain.readyplayer.me/avatar';

  /// Публичный демо URL (работает без настройки)
  static String get publicDemoUrl =>
      'https://readyplayer.me/avatar?frameApi&bodyType=fullbody&language=en';

  /// Получение полного URL с параметрами
  static String getFullUrl({Map<String, String>? customParams}) {
    final params = <String>['frameApi']; // Обязательно для API

    // Добавляем App ID если настроен
    if (isConfigured) {
      params.add('appId=$appId');
    }

    // Добавляем стандартные параметры
    defaultParams.forEach((key, value) {
      params.add('$key=$value');
    });

    // Добавляем кастомные параметры
    customParams?.forEach((key, value) {
      params.add('$key=$value');
    });

    return isConfigured
        ? '$baseUrl?${params.join('&')}'
        : '$publicDemoUrl&${params.skip(1).join('&')}';
  }

  /// Инструкции по настройке
  static List<String> get setupInstructions => [
        '1. Зарегистрируйтесь на https://readyplayer.me/',
        '2. Войдите в https://studio.readyplayer.me/',
        '3. Создайте новое приложение',
        '4. Скопируйте ваш поддомен и App ID',
        '5. Замените значения в lib/core/config/rpm_config.dart',
        '6. Перезапустите приложение',
      ];

  /// Ссылки для регистрации
  static const Map<String, String> links = {
    'register': 'https://readyplayer.me/',
    'studio': 'https://studio.readyplayer.me/',
    'docs': 'https://docs.readyplayer.me/',
    'support': 'https://readyplayer.me/support',
  };
}
