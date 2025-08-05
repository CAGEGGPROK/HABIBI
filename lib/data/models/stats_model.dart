import 'package:hive/hive.dart';

part 'stats_model.g.dart'; // Сгенерированный файл для Hive

/// Модель статистики персонажа
@HiveType(typeId: 2)
class StatsModel extends HiveObject {
  /// ID пользователя, которому принадлежат статы
  @HiveField(0)
  final String userId;
  
  /// Здоровье (0-100)
  @HiveField(1)
  double health;
  
  /// Доход/Финансы (0-100)
  @HiveField(2)
  double income;
  
  /// Спорт/Физическая форма (0-100)
  @HiveField(3)
  double sport;
  
  /// Личная жизнь/Отношения (0-100)
  @HiveField(4)
  double love;
  
  /// Социальная жизнь/Друзья (0-100)
  @HiveField(5)
  double social;
  
  /// Образование/Саморазвитие (0-100)
  @HiveField(6)
  double education;
  
  /// Карьера/Работа (0-100)
  @HiveField(7)
  double career;
  
  /// Хобби/Творчество (0-100)
  @HiveField(8)
  double hobby;
  
  /// Духовность/Медитация (0-100)
  @HiveField(9)
  double spirituality;
  
  /// Отдых/Развлечения (0-100)
  @HiveField(10)
  double entertainment;
  
  /// Дата последнего обновления статов
  @HiveField(11)
  DateTime lastUpdated;
  
  /// История изменений статов (для графиков)
  @HiveField(12)
  List<StatsHistory> history;
  
  /// Общий баланс жизни (среднее всех статов)
  @HiveField(13)
  double lifeBalance;
  
  StatsModel({
    required this.userId,
    this.health = 50.0,
    this.income = 50.0,
    this.sport = 50.0,
    this.love = 50.0,
    this.social = 50.0,
    this.education = 50.0,
    this.career = 50.0,
    this.hobby = 50.0,
    this.spirituality = 50.0,
    this.entertainment = 50.0,
    required this.lastUpdated,
    List<StatsHistory>? history,
    double? lifeBalance,
  }) : history = history ?? [],
        lifeBalance = lifeBalance ?? 50.0 {
    // Пересчитываем баланс при создании
    updateLifeBalance();
  }
  
  /// Получение всех статов в виде карты
  Map<String, double> get allStats => {
    'health': health,
    'income': income,
    'sport': sport,
    'love': love,
    'social': social,
    'education': education,
    'career': career,
    'hobby': hobby,
    'spirituality': spirituality,
    'entertainment': entertainment,
  };
  
  /// Получение стата по имени
  double getStatByName(String statName) {
    switch (statName) {
      case 'health':
        return health;
      case 'income':
        return income;
      case 'sport':
        return sport;
      case 'love':
        return love;
      case 'social':
        return social;
      case 'education':
        return education;
      case 'career':
        return career;
      case 'hobby':
        return hobby;
      case 'spirituality':
        return spirituality;
      case 'entertainment':
        return entertainment;
      default:
        return 0.0;
    }
  }
  
  /// Обновление стата по имени
  void updateStat(String statName, double value) {
    // Ограничиваем значение от 0 до 100
    value = value.clamp(0.0, 100.0);
    
    switch (statName) {
      case 'health':
        health = value;
        break;
      case 'income':
        income = value;
        break;
      case 'sport':
        sport = value;
        break;
      case 'love':
        love = value;
        break;
      case 'social':
        social = value;
        break;
      case 'education':
        education = value;
        break;
      case 'career':
        career = value;
        break;
      case 'hobby':
        hobby = value;
        break;
      case 'spirituality':
        spirituality = value;
        break;
      case 'entertainment':
        entertainment = value;
        break;
    }
    
    lastUpdated = DateTime.now();
    updateLifeBalance();
    addToHistory();
  }
  
  /// Увеличение стата на определенное значение
  void increaseStat(String statName, double amount) {
    final currentValue = getStatByName(statName);
    updateStat(statName, currentValue + amount);
  }
  
  /// Уменьшение стата на определенное значение
  void decreaseStat(String statName, double amount) {
    final currentValue = getStatByName(statName);
    updateStat(statName, currentValue - amount);
  }
  
  /// Обновление общего баланса жизни
  void updateLifeBalance() {
    final sum = health + income + sport + love + social + 
                education + career + hobby + spirituality + entertainment;
    lifeBalance = sum / 10;
  }
  
  /// Добавление текущего состояния в историю
  void addToHistory() {
    // Сохраняем историю только раз в день
    if (history.isNotEmpty) {
      final lastEntry = history.last;
      if (lastEntry.date.day == DateTime.now().day &&
          lastEntry.date.month == DateTime.now().month &&
          lastEntry.date.year == DateTime.now().year) {
        // Обновляем последнюю запись за сегодня
        history[history.length - 1] = StatsHistory(
          date: DateTime.now(),
          stats: Map.from(allStats),
          lifeBalance: lifeBalance,
        );
        return;
      }
    }
    
    // Добавляем новую запись
    history.add(StatsHistory(
      date: DateTime.now(),
      stats: Map.from(allStats),
      lifeBalance: lifeBalance,
    ));
    
    // Ограничиваем историю последними 365 днями
    if (history.length > 365) {
      history.removeAt(0);
    }
  }
  
  /// Получение истории за определенный период
  List<StatsHistory> getHistoryForPeriod(int days) {
    final startDate = DateTime.now().subtract(Duration(days: days));
    return history.where((entry) => entry.date.isAfter(startDate)).toList();
  }
  
  /// Применение ежедневного ухудшения статов (для реалистичности)
  void applyDailyDecay(double decayRate) {
    // Уменьшаем все статы на небольшое значение каждый день
    allStats.forEach((key, value) {
      if (value > 0) {
        updateStat(key, value - decayRate);
      }
    });
  }
  
  /// Копирование модели с изменениями
  StatsModel copyWith({
    double? health,
    double? income,
    double? sport,
    double? love,
    double? social,
    double? education,
    double? career,
    double? hobby,
    double? spirituality,
    double? entertainment,
    DateTime? lastUpdated,
    List<StatsHistory>? history,
  }) {
    return StatsModel(
      userId: userId,
      health: health ?? this.health,
      income: income ?? this.income,
      sport: sport ?? this.sport,
      love: love ?? this.love,
      social: social ?? this.social,
      education: education ?? this.education,
      career: career ?? this.career,
      hobby: hobby ?? this.hobby,
      spirituality: spirituality ?? this.spirituality,
      entertainment: entertainment ?? this.entertainment,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      history: history ?? this.history,
    );
  }
}

/// Модель для хранения истории изменений статов
@HiveType(typeId: 5)
class StatsHistory {
  /// Дата записи
  @HiveField(0)
  final DateTime date;
  
  /// Значения статов на эту дату
  @HiveField(1)
  final Map<String, double> stats;
  
  /// Общий баланс жизни на эту дату
  @HiveField(2)
  final double lifeBalance;
  
  StatsHistory({
    required this.date,
    required this.stats,
    required this.lifeBalance,
  });
}