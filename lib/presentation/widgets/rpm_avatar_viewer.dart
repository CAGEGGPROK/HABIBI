import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../services/rpm_service.dart';

/// Виджет для отображения 3D аватара Ready Player Me
class RPMAvatarViewer extends StatefulWidget {
  final String avatarUrl;
  final String? avatarId;
  final double width;
  final double height;
  final bool enableInteraction;
  final bool showControls;
  final String? localPath;
  final Function(String)? onError;

  const RPMAvatarViewer({
    super.key,
    required this.avatarUrl,
    this.avatarId,
    this.width = 200,
    this.height = 300,
    this.enableInteraction = true,
    this.showControls = false,
    this.localPath,
    this.onError,
  });

  @override
  State<RPMAvatarViewer> createState() => _RPMAvatarViewerState();
}

class _RPMAvatarViewerState extends State<RPMAvatarViewer> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _useLocalFile = false;

  @override
  void initState() {
    super.initState();
    _checkLocalFile();
  }

  /// Проверка наличия локального файла
  Future<void> _checkLocalFile() async {
    if (widget.localPath != null) {
      final file = File(widget.localPath!);
      if (await file.exists()) {
        setState(() {
          _useLocalFile = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 3D модель
            _build3DModel(),

            // Индикатор загрузки
            if (_isLoading)
              Container(
                color: AppColors.background.withOpacity(0.8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Загружаем 3D модель...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Ошибка загрузки
            if (_hasError)
              Container(
                color: AppColors.background.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ошибка загрузки\n3D модели',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Показываем превью вместо 3D
                      _buildPreviewFallback(),
                    ],
                  ),
                ),
              ),

            // Элементы управления
            if (widget.showControls && !_isLoading && !_hasError)
              _buildControls(),
          ],
        ),
      ),
    );
  }

  /// Построение 3D модели
  Widget _build3DModel() {
    String src;

    if (_useLocalFile && widget.localPath != null) {
      // Используем локальный файл
      src = widget.localPath!;
    } else {
      // Используем URL из сети
      src = widget.avatarUrl;
    }

    return ModelViewer(
      src: src,
      alt: 'RPM Avatar',
      ar: false,
      autoRotate: false,
      cameraControls: widget.enableInteraction,
      disableZoom: !widget.enableInteraction,
      backgroundColor: const Color(0xFFEEEEEE),

      // Настройки камеры для лучшего отображения персонажа
      cameraOrbit: '0deg 75deg 2.5m',
      minCameraOrbit: 'auto 0deg auto',
      maxCameraOrbit: 'auto 180deg auto',

      // Настройки окружения
      environmentImage: null, // Убираем environment image
      exposure: 1.0, // Число вместо строки
      shadowIntensity: 0.7, // Число вместо строки
      shadowSoftness: 1.0, // Число вместо строки

      // Анимации (если поддерживаются)
      animationName: '',
      autoPlay: false,

      // Обработчики событий
      onWebViewCreated: (controller) {
        debugPrint('ModelViewer WebView создан');
      },

      // Обработка ошибок через JavaScript
      loading: Loading.eager,

      // Дополнительные параметры
      interactionPrompt: InteractionPrompt.none,

      // JavaScript для обработки событий
      relatedJs: '''
        document.querySelector('model-viewer').addEventListener('error', function(event) {
          console.error('ModelViewer ошибка:', event.detail);
        });
        
        document.querySelector('model-viewer').addEventListener('load', function() {
          console.log('ModelViewer загружен успешно');
        });
      ''',
    );
  }

  /// Элементы управления
  Widget _buildControls() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Column(
        children: [
          // Кнопка сброса камеры
          FloatingActionButton.small(
            heroTag: 'reset_camera',
            onPressed: _resetCamera,
            backgroundColor: AppColors.surface.withOpacity(0.9),
            foregroundColor: AppColors.primary,
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 8),

          // Кнопка переключения источника
          FloatingActionButton.small(
            heroTag: 'toggle_source',
            onPressed: _toggleSource,
            backgroundColor: AppColors.surface.withOpacity(0.9),
            foregroundColor: AppColors.primary,
            child: Icon(_useLocalFile ? Icons.cloud : Icons.storage),
          ),
        ],
      ),
    );
  }

  /// Превью в случае ошибки 3D
  Widget _buildPreviewFallback() {
    if (widget.avatarId == null) {
      return const SizedBox.shrink();
    }

    final previewUrl = RPMService().getAvatarPreviewUrl(
      widget.avatarId!,
      size: 256,
    );

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: previewUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.surfaceVariant,
            child: const Icon(
              Icons.person,
              size: 48,
              color: AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }

  /// Сброс позиции камеры
  void _resetCamera() {
    // Здесь можно добавить JavaScript код для сброса камеры
    debugPrint('Сброс камеры ModelViewer');
  }

  /// Переключение источника модели
  void _toggleSource() {
    setState(() {
      _useLocalFile = !_useLocalFile;
      _isLoading = true;
      _hasError = false;
    });
  }

  /// Обработка ошибки загрузки
  void _handleError(String error) {
    setState(() {
      _hasError = true;
      _errorMessage = error;
      _isLoading = false;
    });

    if (widget.onError != null) {
      widget.onError!(error);
    }
  }
}

/// Виджет-обертка для простого использования
class SimpleRPMAvatar extends StatelessWidget {
  final String avatarUrl;
  final String? avatarId;
  final double size;
  final bool showBorder;

  const SimpleRPMAvatar({
    super.key,
    required this.avatarUrl,
    this.avatarId,
    this.size = 150,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.2, // Пропорции для персонажа
      decoration: showBorder
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            )
          : null,
      child: RPMAvatarViewer(
        avatarUrl: avatarUrl,
        avatarId: avatarId,
        width: size,
        height: size * 1.2,
        enableInteraction: true,
        showControls: false,
      ),
    );
  }
}

/// Полноэкранный просмотрщик аватара
class FullscreenRPMViewer extends StatelessWidget {
  final String avatarUrl;
  final String? avatarId;

  const FullscreenRPMViewer({
    super.key,
    required this.avatarUrl,
    this.avatarId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('3D Аватар'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: Center(
        child: RPMAvatarViewer(
          avatarUrl: avatarUrl,
          avatarId: avatarId,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          enableInteraction: true,
          showControls: true,
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Управление'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Поворот: перетаскивание'),
            Text('• Масштаб: жесты щипка'),
            Text('• Центрирование: кнопка центра'),
            Text('• Переключение источника: кнопка облака'),
          ],
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
