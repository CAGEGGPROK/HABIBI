import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/models/task_model.dart';
import '../../data/storage/user_storage.dart';
import '../../data/storage/customization_storage.dart';
import '../../services/task_service.dart';
import '../../services/stats_service.dart';
import '../../services/rpm_service.dart';
import '../widgets/customizable_character.dart';
import '../widgets/stat_bar.dart';
import '../widgets/task_card.dart';
import '../widgets/level_progress_bar.dart';
import '../screens/create_avatar_screen.dart';
import '../screens/rpm_creator_screen.dart';

/// Главный экран приложения с персонажем и задачами
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  UserModel? _user;
  CharacterCustomization? _customization;
  late AnimationController _avatarAnimationController;
  late Animation<double> _avatarAnimation;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initAnimations();
    _checkDailyLogin();
  }

  /// Инициализация анимаций
  void _initAnimations() {
    _avatarAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _avatarAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController,
      curve: Curves.easeInOut,
    ));

    _avatarAnimationController.repeat(reverse: true);
  }

  /// Загрузка данных пользователя
  Future<void> _loadUser() async {
    final user = await UserStorage.getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
      });

      // Загружаем кастомизацию персонажа
      _customization = await CustomizationStorage.loadCustomization(user.id);
      if (_customization == null) {
        // Если нет сохраненной кастомизации, создаем базовую
        _customization = CharacterCustomization()..gender = user.gender;
      }
      setState(() {});

      // Загружаем статистику
      final statsService = context.read<StatsService>();
      await statsService.loadStats(user.id);

      // Загружаем задачи
      final taskService = context.read<TaskService>();
      await taskService.loadTasks();
    } else {
      // Если пользователь не найден, возвращаемся на экран создания
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/create-avatar');
      }
    }
  }

  /// Проверка ежедневного входа
  Future<void> _checkDailyLogin() async {
    if (_user == null) return;

    final now = DateTime.now();
    final lastLogin = _user!.lastLoginAt;

    if (lastLogin == null ||
        lastLogin.day != now.day ||
        lastLogin.month != now.month ||
        lastLogin.year != now.year) {
      // Обновляем дату последнего входа
      _user!.lastLoginAt = now;

      // Проверяем серию входов
      if (lastLogin != null) {
        final difference = now.difference(lastLogin).inDays;
        if (difference == 1) {
          // Продолжаем серию
          _user!.incrementStreak();
          _showStreakAnimation();
        } else if (difference > 1) {
          // Серия прервана
          _user!.resetStreak();
        }
      } else {
        // Первый вход
        _user!.incrementStreak();
      }

      await UserStorage.saveUser(_user!);

      // Применяем ежедневное ухудшение статов
      final statsService = context.read<StatsService>();
      statsService.applyDailyDecay();
    }
  }

  /// Показ анимации серии
  void _showStreakAnimation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 64,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              Text(
                'Серия: ${_user!.currentStreak} дней!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Продолжайте в том же духе!',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '+${_user!.currentStreak * 10} бонусных монет',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.incomeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Добавляем бонусные монеты
    _user!.coins += _user!.currentStreak * 10;
    UserStorage.saveUser(_user!);
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final taskService = context.watch<TaskService>();
    final statsService = context.watch<StatsService>();
    final todayTasks = taskService.getTodayTasks();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Шапка с аватаром и статистикой
          SliverAppBar(
            expandedHeight: 420,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Верхняя панель
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Монеты
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on_rounded,
                                    color: AppColors.incomeColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_user!.coins}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Кристаллы
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.diamond_rounded,
                                    color: Colors.cyanAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_user!.gems}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Настройки
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/settings');
                              },
                              icon: const Icon(
                                Icons.settings_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Персонаж с кастомизацией
                      Expanded(
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _avatarAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _avatarAnimation.value,
                                child: _buildAvatarWidget(),
                              );
                            },
                          ),
                        ),
                      ),

                      // Имя и уровень
                      Text(
                        _user!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Прогресс уровня
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: LevelProgressBar(
                          level: _user!.level,
                          currentExp: _user!.currentExp,
                          expToNextLevel: _user!.expToNextLevel,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Статистика персонажа
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Характеристики',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Баланс: ${statsService.currentStats?.lifeBalance.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getBalanceColor(
                              statsService.currentStats?.lifeBalance ?? 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Статы
                  if (statsService.currentStats != null) ...[
                    StatBar(
                      label: 'Здоровье',
                      value: statsService.currentStats!.health,
                      color: AppColors.healthColor,
                      icon: Icons.favorite_rounded,
                    ),
                    const SizedBox(height: 12),
                    StatBar(
                      label: 'Доход',
                      value: statsService.currentStats!.income,
                      color: AppColors.incomeColor,
                      icon: Icons.attach_money_rounded,
                    ),
                    const SizedBox(height: 12),
                    StatBar(
                      label: 'Спорт',
                      value: statsService.currentStats!.sport,
                      color: AppColors.sportColor,
                      icon: Icons.fitness_center_rounded,
                    ),
                    const SizedBox(height: 12),
                    StatBar(
                      label: 'Личная жизнь',
                      value: statsService.currentStats!.love,
                      color: AppColors.loveColor,
                      icon: Icons.favorite_border_rounded,
                    ),
                    const SizedBox(height: 12),
                    StatBar(
                      label: 'Социальная жизнь',
                      value: statsService.currentStats!.social,
                      color: AppColors.socialColor,
                      icon: Icons.people_rounded,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Заголовок задач
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Задачи на сегодня',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/tasks');
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
            ),
          ),

          // Список задач
          if (todayTasks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Нет задач на сегодня',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/tasks');
                      },
                      child: const Text('Создать первую задачу'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = todayTasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TaskCard(
                      task: task,
                      onTap: () => _completeTask(task),
                      onLongPress: () {
                        Navigator.pushNamed(
                          context,
                          '/tasks',
                          arguments: task,
                        );
                      },
                    ),
                  );
                },
                childCount: todayTasks.length,
              ),
            ),

          // Отступ внизу
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),

      // Плавающая кнопка
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/tasks');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новая задача'),
      ),
    );
  }

  /// Построение виджета аватара (RPM или кастомный)
  Widget _buildAvatarWidget() {
    if (_user?.useRpmAvatar == true && _user?.rpmAvatarUrl != null) {
      // Показываем RPM аватар как превью
      return GestureDetector(
        onTap: _showAvatarOptions,
        onLongPress: _openRPMAvatarInfo,
        child: Container(
          width: 150,
          height: 270,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primaryDark.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // RPM логотип
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.view_in_ar_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ready Player Me',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '3D Аватар',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Превью изображение если есть ID
              if (_user!.rpmAvatarId != null)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://render.readyplayer.me/${_user!.rpmAvatarId}.png?pose=A&expression=neutral&size=256x256',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.textHint,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else if (_customization != null) {
      // Показываем кастомный персонаж
      return GestureDetector(
        onTap: _showAvatarOptions,
        child: CustomizableCharacter(
          customization: _customization!,
          size: 150,
        ),
      );
    } else {
      // Показываем заглушку
      return GestureDetector(
        onTap: _showAvatarOptions,
        child: Container(
          width: 150,
          height: 270,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_rounded,
                size: 48,
                color: AppColors.primary,
              ),
              SizedBox(height: 8),
              Text(
                'Создать\nаватар',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Показ информации о RPM аватаре
  void _openRPMAvatarInfo() {
    if (_user?.rpmAvatarUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ready Player Me Аватар'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_user!.rpmAvatarId != null)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://render.readyplayer.me/${_user!.rpmAvatarId}.png?pose=A&expression=neutral&size=512x512',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.view_in_ar_rounded,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Персонаж: ${_user!.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${_user!.rpmAvatarId ?? "Неизвестно"}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Здесь можно добавить просмотр полной 3D модели
            },
            child: const Text('3D Просмотр'),
          ),
        ],
      ),
    );
  }

  /// Показ опций аватара
  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAvatarOptionsSheet(),
    );
  }

  /// Лист с опциями аватара
  Widget _buildAvatarOptionsSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Настройки аватара',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Кнопка создания RPM аватара
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.view_in_ar_rounded,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Создать 3D аватар'),
            subtitle: const Text('Ready Player Me'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RPMCreatorScreen(),
                ),
              );
            },
          ),

          // Кнопка кастомного персонажа
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.palette_rounded,
                color: AppColors.accent,
              ),
            ),
            title: const Text('Настроить персонажа'),
            subtitle: const Text('Кастомизация'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateAvatarScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Выполнение задачи
  Future<void> _completeTask(TaskModel task) async {
    if (task.isCompletedToday()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Задача уже выполнена сегодня'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Отмечаем задачу как выполненную
    final taskService = context.read<TaskService>();
    await taskService.completeTask(task);

    // Добавляем опыт и обновляем статы
    final statsService = context.read<StatsService>();
    statsService.increaseStat(task.affectedStat, 5.0);

    _user!.addExperience(task.calculatedExpReward);
    _user!.coins += task.calculatedCoinReward;
    _user!.totalTasksCompleted++;
    await UserStorage.saveUser(_user!);

    setState(() {});

    // Показываем награду
    _showRewardAnimation(task);
  }

  /// Показ анимации награды
  void _showRewardAnimation(TaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Задача выполнена!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '+${task.calculatedExpReward} опыта, +${task.calculatedCoinReward} монет',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Получение цвета для баланса жизни
  Color _getBalanceColor(double balance) {
    if (balance >= 80) return AppColors.success;
    if (balance >= 60) return AppColors.sportColor;
    if (balance >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
