import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Модель пользователя для хранения данных о персонаже
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  /// Уникальный идентификатор пользователя
  @HiveField(0)
  final String id;

  /// Имя персонажа
  @HiveField(1)
  String name;

  /// Путь к локальному файлу аватара
  @HiveField(2)
  String? avatarPath;

  /// URL аватара (если используется из сети)
  @HiveField(3)
  String? avatarUrl;

  /// Текущий уровень персонажа
  @HiveField(4)
  int level;

  /// Текущий опыт персонажа
  @HiveField(5)
  int currentExp;

  /// Опыт, необходимый для следующего уровня
  @HiveField(6)
  int expToNextLevel;

  /// Общее количество выполненных задач
  @HiveField(7)
  int totalTasksCompleted;

  /// Текущая серия выполнения задач (дней подряд)
  @HiveField(8)
  int currentStreak;

  /// Максимальная серия выполнения задач
  @HiveField(9)
  int maxStreak;

  /// Дата создания персонажа
  @HiveField(10)
  DateTime createdAt;

  /// Дата последнего входа в приложение
  @HiveField(11)
  DateTime? lastLoginAt;

  /// Валюта игры (монеты)
  @HiveField(12)
  int coins;

  /// Премиум валюта (кристаллы)
  @HiveField(13)
  int gems;

  /// Список достижений (ID достижений)
  @HiveField(14)
  List<String> achievements;

  /// Настройки уведомлений
  @HiveField(15)
  bool notificationsEnabled;

  /// Время ежедневных напоминаний
  @HiveField(16)
  String? dailyReminderTime;

  /// Тема приложения (light/dark/system)
  @HiveField(17)
  String theme;

  /// Язык приложения
  @HiveField(18)
  String language;

  /// Байты аватара для веб
  @HiveField(19)
  List<int>? avatarBytes;

  /// Пол персонажа
  @HiveField(20)
  String gender;

  /// Ready Player Me аватар URL (.glb файл)
  @HiveField(21)
  String? rpmAvatarUrl;

  /// Ready Player Me аватар ID
  @HiveField(22)
  String? rpmAvatarId;

  /// Использовать ли RPM аватар вместо кастомного
  @HiveField(23)
  bool useRpmAvatar;

  UserModel({
    required this.id,
    required this.name,
    this.avatarPath,
    this.avatarUrl,
    this.level = 1,
    this.currentExp = 0,
    this.expToNextLevel = 100,
    this.totalTasksCompleted = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    required this.createdAt,
    this.lastLoginAt,
    this.coins = 0,
    this.gems = 0,
    List<String>? achievements,
    this.notificationsEnabled = true,
    this.dailyReminderTime,
    this.theme = 'system',
    this.language = 'ru',
    this.avatarBytes,
    this.gender = 'male',
    this.rpmAvatarUrl,
    this.rpmAvatarId,
    this.useRpmAvatar = false,
  }) : achievements = achievements ?? [];

  /// Проверка наличия аватара
  bool get hasAvatar => avatarPath != null || avatarUrl != null;

  /// Получение пути к аватару (приоритет у локального файла)
  String? get avatar => avatarPath ?? avatarUrl;

  /// Процент прогресса до следующего уровня
  double get levelProgress => currentExp / expToNextLevel;

  /// Добавление опыта и проверка повышения уровня
  void addExperience(int exp) {
    currentExp += exp;

    // Проверка повышения уровня
    while (currentExp >= expToNextLevel) {
      currentExp -= expToNextLevel;
      level++;
      // Увеличиваем требуемый опыт для следующего уровня
      expToNextLevel = calculateExpForLevel(level);

      // Награда за новый уровень
      coins += 50 * level;
      gems += 5;
    }
  }

  /// Расчет требуемого опыта для уровня
  int calculateExpForLevel(int level) {
    // Формула: 100 * level * 1.5
    return (100 * level * 1.5).round();
  }

  /// Увеличение серии выполнения задач
  void incrementStreak() {
    currentStreak++;
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
  }

  /// Сброс серии выполнения задач
  void resetStreak() {
    currentStreak = 0;
  }

  /// Добавление достижения
  void addAchievement(String achievementId) {
    if (!achievements.contains(achievementId)) {
      achievements.add(achievementId);
      // Награда за достижение
      gems += 10;
    }
  }

  /// Копирование модели с изменениями
  UserModel copyWith({
    String? name,
    String? avatarPath,
    String? avatarUrl,
    int? level,
    int? currentExp,
    int? expToNextLevel,
    int? totalTasksCompleted,
    int? currentStreak,
    int? maxStreak,
    DateTime? lastLoginAt,
    int? coins,
    int? gems,
    List<String>? achievements,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    String? theme,
    String? language,
    List<int>? avatarBytes,
    String? gender,
    String? rpmAvatarUrl,
    String? rpmAvatarId,
    bool? useRpmAvatar,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      expToNextLevel: expToNextLevel ?? this.expToNextLevel,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      achievements: achievements ?? this.achievements,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      gender: gender ?? this.gender,
      rpmAvatarUrl: rpmAvatarUrl ?? this.rpmAvatarUrl,
      rpmAvatarId: rpmAvatarId ?? this.rpmAvatarId,
      useRpmAvatar: useRpmAvatar ?? this.useRpmAvatar,
    );
  }
}
