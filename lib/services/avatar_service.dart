import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Сервис для работы с аватарами пользователя
class AvatarService extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();
  
  /// Текущий путь к аватару
  String? _currentAvatarPath;
  String? get currentAvatarPath => _currentAvatarPath;
  
  /// Байты изображения для веб
  Uint8List? _imageBytes;
  Uint8List? get imageBytes => _imageBytes;
  
  /// Загружается ли аватар
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  /// Ошибка при работе с аватаром
  String? _error;
  String? get error => _error;
  
  /// Выбор фото из галереи
  Future<XFile?> pickImageFromGallery() async {
    try {
      _setLoading(true);
      _error = null;
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        if (kIsWeb) {
          // Для веб сохраняем байты изображения
          _imageBytes = await pickedFile.readAsBytes();
          _currentAvatarPath = pickedFile.path;
        }
        notifyListeners();
        return pickedFile;
      }
      return null;
    } catch (e) {
      _error = 'Ошибка при выборе изображения: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Съемка фото с камеры
  Future<XFile?> takePhotoFromCamera() async {
    try {
      _setLoading(true);
      _error = null;
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      
      if (pickedFile != null) {
        if (kIsWeb) {
          // Для веб сохраняем байты изображения
          _imageBytes = await pickedFile.readAsBytes();
          _currentAvatarPath = pickedFile.path;
        }
        notifyListeners();
        return pickedFile;
      }
      return null;
    } catch (e) {
      _error = 'Ошибка при съемке фото: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Мок-функция для генерации аватара (для тестирования без API)
  Future<String?> generateMockAvatar(XFile photoFile) async {
    try {
      _setLoading(true);
      _error = null;
      
      // Имитация задержки API
      await Future.delayed(const Duration(seconds: 1));
      
      if (kIsWeb) {
        // Для веб сохраняем байты и возвращаем путь
        _imageBytes = await photoFile.readAsBytes();
        _currentAvatarPath = photoFile.path;
        return photoFile.path;
      } else {
        // Для мобильных платформ
        final directory = await getApplicationDocumentsDirectory();
        final avatarDir = Directory('${directory.path}/avatars');
        
        if (!await avatarDir.exists()) {
          await avatarDir.create(recursive: true);
        }
        
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final avatarPath = path.join(avatarDir.path, fileName);
        
        // Копируем фото в папку аватаров
        final File photoFileObj = File(photoFile.path);
        await photoFileObj.copy(avatarPath);
        
        _currentAvatarPath = avatarPath;
        return avatarPath;
      }
    } catch (e) {
      _error = 'Ошибка при сохранении аватара: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Загрузка существующего аватара
  Future<void> loadAvatar(String? avatarPath) async {
    if (avatarPath != null && await File(avatarPath).exists()) {
      _currentAvatarPath = avatarPath;
      notifyListeners();
    }
  }
  
  /// Удаление аватара
  Future<void> deleteAvatar() async {
    if (_currentAvatarPath != null) {
      final file = File(_currentAvatarPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentAvatarPath = null;
      _imageBytes = null;
      notifyListeners();
    }
  }
  
  /// Получение списка стилей для генерации аватара
  List<AvatarStyle> getAvailableStyles() {
    return [
      AvatarStyle(
        id: 'cartoon',
        name: 'Мультяшный',
        description: 'Веселый и яркий стиль',
        previewImage: 'assets/images/style_cartoon.png',
      ),
      AvatarStyle(
        id: 'anime',
        name: 'Аниме',
        description: 'В стиле японской анимации',
        previewImage: 'assets/images/style_anime.png',
      ),
      AvatarStyle(
        id: 'realistic',
        name: 'Реалистичный',
        description: 'Максимально похожий на фото',
        previewImage: 'assets/images/style_realistic.png',
      ),
      AvatarStyle(
        id: 'pixel',
        name: 'Пиксельный',
        description: '8-битный ретро стиль',
        previewImage: 'assets/images/style_pixel.png',
      ),
      AvatarStyle(
        id: 'fantasy',
        name: 'Фэнтези',
        description: 'Эпический герой RPG',
        previewImage: 'assets/images/style_fantasy.png',
      ),
    ];
  }
  
  /// Установка состояния загрузки
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  /// Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Модель стиля аватара
class AvatarStyle {
  final String id;
  final String name;
  final String description;
  final String previewImage;
  
  AvatarStyle({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
  });
}