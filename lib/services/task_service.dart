import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/task_model.dart';

/// Сервис для управления задачами
class TaskService extends ChangeNotifier {
  static const String _boxName = 'tasks';
  late Box<TaskModel> _taskBox;
  List<TaskModel> _tasks = [];
  
  /// Список всех задач
  List<TaskModel> get allTasks => _tasks;
  
  /// Список активных задач
  List<TaskModel> get activeTasks => 
      _tasks.where((task) => task.isActive).toList();
  
  /// Список задач на сегодня
  List<TaskModel> getTodayTasks() {
    return activeTasks
        .where((task) => task.shouldBeCompletedToday())
        .toList()
      ..sort((a, b) {
        // Сортировка по приоритету
        if (a.priority != b.priority) {
          return b.priority.index.compareTo(a.priority.index);
        }
        // Затем по времени напоминания
        if (a.reminderTime != null && b.reminderTime != null) {
          return a.reminderTime!.compareTo(b.reminderTime!);
        }
        return 0;
      });
  }
  
  /// Список выполненных сегодня задач
  List<TaskModel> getCompletedTodayTasks() {
    return _tasks.where((task) => task.isCompletedToday()).toList();
  }
  
  /// Загрузка задач из хранилища
  Future<void> loadTasks() async {
    _taskBox = await Hive.openBox<TaskModel>(_boxName);
    _tasks = _taskBox.values.toList();
    
    // Сбрасываем ежедневные задачи, если новый день
    _resetDailyTasks();
    
    notifyListeners();
  }
  
  /// Добавление новой задачи
  Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
    _tasks.add(task);
    notifyListeners();
  }
  
  /// Обновление задачи
  Future<void> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      await _taskBox.put(task.id, task);
      _tasks[index] = task;
      notifyListeners();
    }
  }
  
  /// Удаление задачи
  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }
  
  /// Отметить задачу как выполненную
  Future<void> completeTask(TaskModel task) async {
    task.markAsCompleted();
    await updateTask(task);
  }
  
  /// Получение задач по категории (стату)
  List<TaskModel> getTasksByStat(String statName) {
    return activeTasks
        .where((task) => task.affectedStat == statName)
        .toList();
  }
  
  /// Получение задач по типу
  List<TaskModel> getTasksByType(TaskType type) {
    return activeTasks
        .where((task) => task.type == type)
        .toList();
  }
  
  /// Сброс ежедневных задач
  void _resetDailyTasks() {
    final now = DateTime.now();
    
    for (var task in _tasks) {
      if (task.type == TaskType.daily || task.type == TaskType.weekly) {
        // Проверяем, нужно ли сбросить задачу
        if (task.lastCompletedAt != null) {
          final lastCompleted = task.lastCompletedAt!;
          
          // Если последнее выполнение было не сегодня
          if (lastCompleted.day != now.day ||
              lastCompleted.month != now.month ||
              lastCompleted.year != now.year) {
            task.resetCompletion();
            _taskBox.put(task.id, task);
          }
        }
      }
    }
  }
  
  /// Получение статистики по задачам
  Map<String, dynamic> getTasksStatistics() {
    final totalTasks = _tasks.length;
    final completedToday = getCompletedTodayTasks().length;
    final pendingToday = getTodayTasks().where((t) => !t.isCompleted).length;
    
    // Подсчет по типам
    final dailyCount = getTasksByType(TaskType.daily).length;
    final weeklyCount = getTasksByType(TaskType.weekly).length;
    final customCount = getTasksByType(TaskType.custom).length;
    final habitCount = getTasksByType(TaskType.habit).length;
    
    // Общее количество выполнений
    final totalCompletions = _tasks.fold<int>(
      0,
      (sum, task) => sum + task.completionCount,
    );
    
    return {
      'total': totalTasks,
      'completedToday': completedToday,
      'pendingToday': pendingToday,
      'daily': dailyCount,
      'weekly': weeklyCount,
      'custom': customCount,
      'habit': habitCount,
      'totalCompletions': totalCompletions,
    };
  }
  
  /// Создание примеров задач для нового пользователя
  Future<void> createSampleTasks() async {
    final sampleTasks = [
      TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Утренняя зарядка',
        description: 'Сделать 10-минутную разминку',
        type: TaskType.daily,
        priority: TaskPriority.high,
        affectedStat: 'sport',
        expReward: 15,
        coinReward: 10,
        createdAt: DateTime.now(),
        icon: '🏃',
        reminderTime: '07:00',
      ),
      TaskModel(
        id: '${DateTime.now().millisecondsSinceEpoch + 1}',
        title: 'Выпить 2 литра воды',
        description: 'Поддерживать водный баланс',
        type: TaskType.daily,
        priority: TaskPriority.medium,
        affectedStat: 'health',
        expReward: 10,
        coinReward: 5,
        createdAt: DateTime.now(),
        icon: '💧',
      ),
      TaskModel(
        id: '${DateTime.now().millisecondsSinceEpoch + 2}',
        title: 'Чтение книги',
        description: 'Прочитать минимум 20 страниц',
        type: TaskType.daily,
        priority: TaskPriority.medium,
        affectedStat: 'education',
        expReward: 20,
        coinReward: 15,
        createdAt: DateTime.now(),
        icon: '📚',
        reminderTime: '20:00',
      ),
      TaskModel(
        id: '${DateTime.now().millisecondsSinceEpoch + 3}',
        title: 'Встреча с друзьями',
        description: 'Провести время с близкими',
        type: TaskType.weekly,
        priority: TaskPriority.medium,
        affectedStat: 'social',
        expReward: 30,
        coinReward: 20,
        createdAt: DateTime.now(),
        weekDays: [5, 6], // Пятница и суббота
        icon: '👥',
      ),
      TaskModel(
        id: '${DateTime.now().millisecondsSinceEpoch + 4}',
        title: 'Медитация',
        description: 'Практика осознанности',
        type: TaskType.habit,
        priority: TaskPriority.low,
        affectedStat: 'spirituality',
        expReward: 10,
        coinReward: 5,
        createdAt: DateTime.now(),
        icon: '🧘',
        difficulty: 2,
      ),
    ];
    
    for (var task in sampleTasks) {
      await addTask(task);
    }
  }
}