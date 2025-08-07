import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Утилитарный класс для работы с WebView и обработки ошибок
class WebViewHelper {
  /// Проверка поддержки WebView на устройстве
  static Future<bool> isWebViewSupported() async {
    try {
      // Попытка создать контроллер для проверки поддержки
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      return true;
    } catch (e) {
      debugPrint('WebView не поддерживается: $e');
      return false;
    }
  }

  /// Получение User Agent для лучшей совместимости с RPM
  static String getUserAgent() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';
    } else {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Safari/537.36';
    }
  }

  /// Стандартные настройки WebViewController для RPM
  static Future<WebViewController> createRPMWebViewController({
    required NavigationDelegate navigationDelegate,
    required Function(JavaScriptMessage) onMessageReceived,
  }) async {
    final controller = WebViewController();

    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setUserAgent(getUserAgent());
    await controller.setNavigationDelegate(navigationDelegate);

    // Добавляем канал для JavaScript сообщений
    await controller.addJavaScriptChannel(
      'FlutterApp',
      onMessageReceived: onMessageReceived,
    );

    // Настройки для лучшей производительности
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Дополнительные настройки для Android
      debugPrint('Настройка WebView для Android');
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Дополнительные настройки для iOS
      debugPrint('Настройка WebView для iOS');
    }

    return controller;
  }

  /// JavaScript код для интеграции с Ready Player Me
  static String getRPMIntegrationScript() {
    return '''
    (function() {
      console.log('🚀 RPM Integration Script Loading...');
      
      // Функция для безопасной отправки сообщений в Flutter
      function sendToFlutter(data) {
        try {
          if (window.FlutterApp && window.FlutterApp.postMessage) {
            const message = JSON.stringify(data);
            window.FlutterApp.postMessage(message);
            console.log('✅ Message sent to Flutter:', data);
            return true;
          } else {
            console.error('❌ FlutterApp channel not found');
            return false;
          }
        } catch (error) {
          console.error('❌ Error sending message to Flutter:', error);
          return false;
        }
      }
      
      // Глобальный обработчик ошибок
      window.addEventListener('error', function(event) {
        console.error('Page error:', event.error);
        sendToFlutter({
          eventName: 'page.error',
          data: { error: event.error.message, source: event.filename, line: event.lineno },
          source: 'window'
        });
      });
      
      // Обработчик сообщений от Ready Player Me
      window.addEventListener('message', function(event) {
        console.log('📨 RPM Message received:', event);
        
        if (!event.data) {
          console.log('📭 Empty message data');
          return;
        }
        
        try {
          let data = event.data;
          
          // Парсим JSON если нужно
          if (typeof data === 'string' && data.startsWith('{')) {
            try {
              data = JSON.parse(data);
            } catch (parseError) {
              console.log('📝 Data is not JSON, treating as string');
            }
          }
          
          // Определяем тип события
          const eventName = data.eventName || data.type || 'unknown';
          console.log('🎯 Event type:', eventName);
          
          // Отправляем в Flutter
          const success = sendToFlutter({
            eventName: eventName,
            data: data.data || data,
            source: 'rpm',
            timestamp: Date.now(),
            originalEvent: data
          });
          
          if (!success) {
            console.error('❌ Failed to send event to Flutter');
          }
          
        } catch (error) {
          console.error('❌ Error processing RPM event:', error);
          sendToFlutter({
            eventName: 'error',
            data: { error: error.message, originalData: event.data },
            source: 'rpm'
          });
        }
      });
      
      // Перехватываем все postMessage вызовы для отладки
      const originalPostMessage = window.postMessage;
      window.postMessage = function(message, targetOrigin) {
        console.log('📤 PostMessage intercepted:', message);
        
        // Отправляем в Flutter для анализа
        sendToFlutter({
          eventName: 'postMessage.intercepted',
          data: message,
          source: 'window',
          targetOrigin: targetOrigin
        });
        
        return originalPostMessage.call(this, message, targetOrigin);
      };
      
      // Проверяем готовность Ready Player Me
      function checkRPMReady() {
        const iframe = document.querySelector('iframe');
        if (iframe) {
          console.log('🎯 RPM iframe found');
          sendToFlutter({
            eventName: 'rpm.iframe.found',
            data: { src: iframe.src },
            source: 'integration'
          });
        } else {
          console.log('⏳ RPM iframe not found yet, checking again...');
          setTimeout(checkRPMReady, 1000);
        }
      }
      
      // Уведомляем Flutter о готовности интеграции
      setTimeout(() => {
        sendToFlutter({
          eventName: 'integration.ready',
          data: { 
            status: 'ready', 
            url: window.location.href,
            userAgent: navigator.userAgent,
            timestamp: Date.now()
          },
          source: 'integration'
        });
        
        // Начинаем проверку RPM
        checkRPMReady();
      }, 500);
      
      console.log('✅ RPM Integration Script Loaded Successfully');
    })();
    ''';
  }

  /// Проверка URL на валидность для Ready Player Me
  static bool isValidRPMUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('readyplayer.me') ||
          uri.host.contains('models.readyplayer.me');
    } catch (e) {
      return false;
    }
  }

  /// Получение запасного URL для Ready Player Me
  static String getFallbackRPMUrl() {
    return 'https://demo.readyplayer.me/avatar?frameApi&bodyType=fullbody';
  }

  /// Обработка ошибок WebView
  static String getErrorMessage(WebResourceError error) {
    switch (error.errorType) {
      case WebResourceErrorType.hostLookup:
        return 'Не удается подключиться к серверу Ready Player Me. Проверьте интернет-соединение.';
      case WebResourceErrorType.timeout:
        return 'Превышено время ожидания. Попробуйте еще раз.';
      case WebResourceErrorType.connect:
        return 'Ошибка подключения к серверу.';
      case WebResourceErrorType.unknown:
        return 'Неизвестная ошибка при загрузке Ready Player Me.';
      default:
        return 'Ошибка загрузки: ${error.description}';
    }
  }

  /// Диагностическая информация для отладки
  static Map<String, dynamic> getDiagnosticInfo() {
    return {
      'platform': defaultTargetPlatform.toString(),
      'isWeb': kIsWeb,
      'debug': kDebugMode,
      'userAgent': getUserAgent(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
