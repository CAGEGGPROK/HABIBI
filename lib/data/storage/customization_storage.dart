import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/create_avatar_screen.dart';

/// Класс для сохранения и загрузки кастомизации персонажа
class CustomizationStorage {
  static const String _boxName = 'customizations';
  
  /// Сохранение кастомизации
  static Future<void> saveCustomization(String userId, CharacterCustomization customization) async {
    final box = await Hive.openBox(_boxName);
    
    // Преобразуем в Map для сохранения
    final data = {
      'userId': userId,
      'gender': customization.gender,
      'height': customization.height,
      'bodyBuild': customization.bodyBuild,
      'headSize': customization.headSize,
      'armLength': customization.armLength,
      'legLength': customization.legLength,
      'shoulderWidth': customization.shoulderWidth,
      'faceShape': customization.faceShape,
      'noseShape': customization.noseShape,
      'lipsShape': customization.lipsShape,
      'chinShape': customization.chinShape,
      'skinColor': customization.skinColor.value,
      'hairStyle': customization.hairStyle,
      'hairColor': customization.hairColor.value,
      'facialHair': customization.facialHair,
      'eyeShape': customization.eyeShape,
      'eyeColor': customization.eyeColor.value,
      'clothingStyle': customization.clothingStyle,
      'topClothing': customization.topClothing,
      'bottomClothing': customization.bottomClothing,
      'shoes': customization.shoes,
      'accessories': customization.accessories,
    };
    
    await box.put(userId, data);
  }
  
  /// Загрузка кастомизации
  static Future<CharacterCustomization?> loadCustomization(String userId) async {
    final box = await Hive.openBox(_boxName);
    final data = box.get(userId);
    
    if (data == null) return null;
    
    final customization = CharacterCustomization();
    
    // Восстанавливаем из Map
    customization.gender = data['gender'] ?? 'male';
    customization.height = data['height'] ?? 0.5;
    customization.bodyBuild = data['bodyBuild'] ?? 0.5;
    customization.headSize = data['headSize'] ?? 0.5;
    customization.armLength = data['armLength'] ?? 0.5;
    customization.legLength = data['legLength'] ?? 0.5;
    customization.shoulderWidth = data['shoulderWidth'] ?? 0.5;
    customization.faceShape = data['faceShape'] ?? 'Овальное';
    customization.noseShape = data['noseShape'] ?? 'Прямой';
    customization.lipsShape = data['lipsShape'] ?? 'Средние';
    customization.chinShape = data['chinShape'] ?? 'Круглый';
    customization.skinColor = Color(data['skinColor'] ?? 0xFFE8CDA9);
    customization.hairStyle = data['hairStyle'] ?? 'Короткая';
    customization.hairColor = Color(data['hairColor'] ?? Colors.brown.shade800.value);
    customization.facialHair = data['facialHair'] ?? 'Нет';
    customization.eyeShape = data['eyeShape'] ?? 'Миндалевидные';
    customization.eyeColor = Color(data['eyeColor'] ?? Colors.brown.shade600.value);
    customization.clothingStyle = data['clothingStyle'] ?? 'Повседневный';
    customization.topClothing = data['topClothing'] ?? 'Футболка';
    customization.bottomClothing = data['bottomClothing'] ?? 'Джинсы';
    customization.shoes = data['shoes'] ?? 'Кроссовки';
    customization.accessories = List<String>.from(data['accessories'] ?? []);
    
    return customization;
  }
  
  /// Удаление кастомизации
  static Future<void> deleteCustomization(String userId) async {
    final box = await Hive.openBox(_boxName);
    await box.delete(userId);
  }
}