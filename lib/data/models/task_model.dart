import 'package:hive/hive.dart';

part 'task_model.g.dart'; // Сгенерированный файл для Hive

/// Тип задачи
@HiveType(typeId: 3)
enum TaskType {
  @HiveField(0)
  daily, // Ежедневная задача
  
  @HiveField(1)
  weekly, // Еженедельная задача
  
  @HiveField(2)
  custom, // Кастомная задача
  
  @HiveField(3)
  habit, // Привычка (может выполняться несколько раз в день)
}

/// Приоритет задачи
@HiveType(typeId: 4)
enum TaskPriority {
  @HiveField(0)
  low, // Низкий приоритет
  
  @HiveField(1)
  medium, // Средний приоритет
  
  @HiveField(2)
  high, // Высокий приоритет
}

/// Модель задачи
@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  /// Уникальный идентификатор задачи
  @HiveField(0)
  final String id;
  
  /// Название задачи
  @HiveField(1)
  String title;
  
  /// Описание задачи
  @HiveField(2)
  String? description;
  
  /// Тип задачи
  @HiveField(3)
  TaskType type;
  
  /// Приоритет задачи
  @HiveField(4)
  TaskPriority priority;
  
  /// Статистика, на которую влияет выполнение задачи
  @HiveField(5)
  String affectedStat;
  
  /// Количество опыта за выполнение
  @HiveField(6)
  int expReward;
  
  /// Количество монет за выполнение
  @HiveField(7)
  int coinReward;
  
  /// Выполнена ли задача сегодня
  @HiveField(8)
  bool isCompleted;
  
  /// Дата создания задачи
  @HiveField(9)
  DateTime createdAt;
  
  /// Дата последнего выполнения
  @HiveField(10)
  DateTime? lastCompletedAt;
  
  /// Количество выполнений задачи
  @HiveField(11)
  int completionCount;
  
  /// Дни недели для еженедельных задач (1-7, где 1 - понедельник)
  @HiveField(12)
  List<int>? weekDays;
  
  /// Время напоминания о задаче
  @HiveField(13)
  String? reminderTime;
  
  /// Включены ли уведомления для задачи
  @HiveField(14)
  bool notificationsEnabled;
  
  /// Дедлайн для кастомных задач
  @HiveField(15)
  DateTime? deadline;
  
  /// Теги задачи
  @HiveField(16)
  List<String> tags;
  
  /// Заметки к задаче
  @HiveField(17)
  String? notes;
  
  /// Серия выполнения (для ежедневных задач)
  @HiveField(18)
  int streak;
  
  /// Иконка задачи (emoji или название иконки)
  @HiveField(19)
  String? icon;
  
  /// Цвет задачи (hex)
  @HiveField(20)
  String? color;
  
  /// Активна ли задача
  @HiveField(21)
  bool isActive;
  
  /// Сложность задачи (1-5)
  @HiveField(22)
  int difficulty;
  
  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.priority = TaskPriority.medium,
    required this.affectedStat,
    this.expReward = 10,
    this.coinReward = 5,
    this.isCompleted = false,
    required this.createdAt,
    this.lastCompletedAt,
    this.completionCount = 0,
    this.weekDays,
    this.reminderTime,
    this.notificationsEnabled = false,
    this.deadline,
    List<String>? tags,
    this.notes,
    this.streak = 0,
    this.icon,
    this.color,
    this.isActive = true,
    this.difficulty = 1,
  }) : tags = tags ?? [];
  
  /// Расчет награды с учетом сложности и приоритета
  int get calculatedExpReward {
    int baseReward = expReward;
    
    // Множитель за приоритет
    switch (priority) {
      case TaskPriority.low:
        baseReward = (baseReward * 0.8).round();
        break;
      case TaskPriority.medium:
        // Без изменений
        break;
      case TaskPriority.high:
        baseReward = (baseReward * 1.5).round();
        break;
    }
    
    // Множитель за сложность
    baseReward = (baseReward * (1 + (difficulty - 1) * 0.25)).round();
    
    // Бонус за серию выполнения
    if (streak > 0) {
      baseReward += (streak * 2).clamp(0, 50);
    }
    
    return baseReward;
  }
  
  /// Расчет награды в монетах
  int get calculatedCoinReward {
    return (coinReward * (1 + (difficulty - 1) * 0.2)).round();
  }
  
  /// Проверка, нужно ли выполнять задачу сегодня
  bool shouldBeCompletedToday() {
    if (!isActive) return false;
    
    final now = DateTime.now();
    
    switch (type) {
      case TaskType.daily:
        // Ежедневные задачи всегда должны выполняться
        return !isCompletedToday();
        
      case TaskType.weekly:
        // Проверяем, входит ли текущий день недели в список
        if (weekDays != null && weekDays!.isNotEmpty) {
          return weekDays!.contains(now.weekday) && !isCompletedToday();
        }
        return false;
        
      case TaskType.custom:
        // Кастомные задачи проверяем по дедлайну
        if (deadline != null) {
          return now.isBefore(deadline!) && !isCompleted;
        }
        return !isCompleted;
        
      case TaskType.habit:
        // Привычки всегда доступны для выполнения
        return true;
    }
  }
  
  /// Проверка, выполнена ли задача сегодня
  bool isCompletedToday() {
    if (lastCompletedAt == null) return false;
    
    final now = DateTime.now();
    return lastCompletedAt!.year == now.year &&
           lastCompletedAt!.month == now.month &&
           lastCompletedAt!.day == now.day;
  }
  
  /// Отметить задачу как выполненную
  void markAsCompleted() {
    isCompleted = true;
    lastCompletedAt = DateTime.now();
    completionCount++;
    
    // Увеличиваем серию для ежедневных задач
    if (type == TaskType.daily) {
      streak++;
    }
  }
  
  /// Сбросить выполнение задачи
  void resetCompletion() {
    isCompleted = false;
    
    // Сбрасываем серию, если пропущен день
    if (type == TaskType.daily && !isCompletedToday()) {
      streak = 0;
    }
  }
  
  /// Копирование модели с изменениями
  TaskModel copyWith({
    String? title,
    String? description,
    TaskType? type,
    TaskPriority? priority,
    String? affectedStat,
    int? expReward,
    int? coinReward,
    bool? isCompleted,
    DateTime? lastCompletedAt,
    int? completionCount,
    List<int>? weekDays,
    String? reminderTime,
    bool? notificationsEnabled,
    DateTime? deadline,
    List<String>? tags,
    String? notes,
    int? streak,
    String? icon,
    String? color,
    bool? isActive,
    int? difficulty,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      affectedStat: affectedStat ?? this.affectedStat,
      expReward: expReward ?? this.expReward,
      coinReward: coinReward ?? this.coinReward,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      completionCount: completionCount ?? this.completionCount,
      weekDays: weekDays ?? this.weekDays,
      reminderTime: reminderTime ?? this.reminderTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      streak: streak ?? this.streak,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}