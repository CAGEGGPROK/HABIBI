import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/stats_model.dart';

/// Сервис для управления статистикой персонажа
class StatsService extends ChangeNotifier {
  static const String _boxName = 'stats';
  late Box<StatsModel> _statsBox;
  StatsModel? _currentStats;
  
  /// Текущие статы персонажа
  StatsModel? get currentStats => _currentStats;
  
  /// Инициализация статистики для нового пользователя
  Future<void> initializeStats(String userId) async {
    _statsBox = await Hive.openBox<StatsModel>(_boxName);
    
    // Создаем новую статистику
    _currentStats = StatsModel(
      userId: userId,
      lastUpdated: DateTime.now(),
    );
    
    await _statsBox.put(userId, _currentStats!);
    notifyListeners();
  }
  
  /// Загрузка статистики пользователя
  Future<void> loadStats(String userId) async {
    _statsBox = await Hive.openBox<StatsModel>(_boxName);
    _currentStats = _statsBox.get(userId);
    
    if (_currentStats == null) {
      await initializeStats(userId);
    }
    
    notifyListeners();
  }
  
  /// Обновление конкретного стата
  Future<void> updateStat(String statName, double value) async {
    if (_currentStats == null) return;
    
    _currentStats!.updateStat(statName, value);
    await _saveStats();
    notifyListeners();
  }
  
  /// Увеличение стата
  Future<void> increaseStat(String statName, double amount) async {
    if (_currentStats == null) return;
    
    _currentStats!.increaseStat(statName, amount);
    await _saveStats();
    notifyListeners();
  }
  
  /// Уменьшение стата
  Future<void> decreaseStat(String statName, double amount) async {
    if (_currentStats == null) return;
    
    _currentStats!.decreaseStat(statName, amount);
    await _saveStats();
    notifyListeners();
  }
  
  /// Применение ежедневного ухудшения статов
  Future<void> applyDailyDecay({double decayRate = 1.0}) async {
    if (_currentStats == null) return;
    
    _currentStats!.applyDailyDecay(decayRate);
    await _saveStats();
    notifyListeners();
  }
  
  /// Получение цвета для стата
  Color getStatColor(String statName) {
    final value = _currentStats?.getStatByName(statName) ?? 0;
    
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.lightGreen;
    if (value >= 40) return Colors.orange;
    if (value >= 20) return Colors.deepOrange;
    return Colors.red;
  }
  
  /// Получение иконки для стата
  IconData getStatIcon(String statName) {
    switch (statName) {
      case 'health':
        return Icons.favorite_rounded;
      case 'income':
        return Icons.attach_money_rounded;
      case 'sport':
        return Icons.fitness_center_rounded;
      case 'love':
        return Icons.favorite_border_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'career':
        return Icons.work_rounded;
      case 'hobby':
        return Icons.palette_rounded;
      case 'spirituality':
        return Icons.self_improvement_rounded;
      case 'entertainment':
        return Icons.sports_esports_rounded;
      default:
        return Icons.star_rounded;
    }
  }
  
  /// Получение названия стата на русском
  String getStatLabel(String statName) {
    switch (statName) {
      case 'health':
        return 'Здоровье';
      case 'income':
        return 'Доход';
      case 'sport':
        return 'Спорт';
      case 'love':
        return 'Личная жизнь';
      case 'social':
        return 'Социальная жизнь';
      case 'education':
        return 'Образование';
      case 'career':
        return 'Карьера';
      case 'hobby':
        return 'Хобби';
      case 'spirituality':
        return 'Духовность';
      case 'entertainment':
        return 'Развлечения';
      default:
        return statName;
    }
  }
  
  /// Получение истории изменений статов
  List<StatsHistory> getHistory({int days = 30}) {
    if (_currentStats == null) return [];
    return _currentStats!.getHistoryForPeriod(days);
  }
  
  /// Получение топ-3 самых низких статов
  List<MapEntry<String, double>> getLowestStats() {
    if (_currentStats == null) return [];
    
    final stats = _currentStats!.allStats.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    return stats.take(3).toList();
  }
  
  /// Получение топ-3 самых высоких статов
  List<MapEntry<String, double>> getHighestStats() {
    if (_currentStats == null) return [];
    
    final stats = _currentStats!.allStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return stats.take(3).toList();
  }
  
  /// Расчет прогресса до идеального баланса
  double getBalanceProgress() {
    if (_currentStats == null) return 0;
    return _currentStats!.lifeBalance / 100;
  }
  
  /// Получение рекомендаций по улучшению статов
  List<String> getRecommendations() {
    if (_currentStats == null) return [];
    
    final recommendations = <String>[];
    final lowestStats = getLowestStats();
    
    for (var stat in lowestStats) {
      if (stat.value < 30) {
        recommendations.add(
          'Обратите внимание на "${getStatLabel(stat.key)}" - всего ${stat.value.toStringAsFixed(0)}%',
        );
      }
    }
    
    if (_currentStats!.lifeBalance < 50) {
      recommendations.add(
        'Ваш жизненный баланс ниже 50%. Старайтесь развивать все сферы жизни равномерно.',
      );
    }
    
    return recommendations;
  }
  
  /// Сохранение статистики
  Future<void> _saveStats() async {
    if (_currentStats != null) {
      await _statsBox.put(_currentStats!.userId, _currentStats!);
    }
  }
  
  /// Сброс всей статистики
  Future<void> resetStats() async {
    if (_currentStats == null) return;
    
    final userId = _currentStats!.userId;
    await initializeStats(userId);
  }
}