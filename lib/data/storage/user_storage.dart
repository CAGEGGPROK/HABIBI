import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

/// Класс для работы с локальным хранилищем пользователей
class UserStorage {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'current_user';
  
  /// Получение текущего пользователя
  static Future<UserModel?> getCurrentUser() async {
    final box = await Hive.openBox<UserModel>(_boxName);
    return box.get(_currentUserKey);
  }
  
  /// Сохранение пользователя
  static Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(_boxName);
    await box.put(_currentUserKey, user);
  }
  
  /// Удаление пользователя
  static Future<void> deleteUser() async {
    final box = await Hive.openBox<UserModel>(_boxName);
    await box.delete(_currentUserKey);
  }
  
  /// Проверка существования пользователя
  static Future<bool> hasUser() async {
    final box = await Hive.openBox<UserModel>(_boxName);
    return box.containsKey(_currentUserKey);
  }
  
  /// Очистка всех данных
  static Future<void> clearAll() async {
    final box = await Hive.openBox<UserModel>(_boxName);
    await box.clear();
  }
}