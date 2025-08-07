import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'data/models/user_model.dart';
import 'data/models/task_model.dart';
import 'data/models/stats_model.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/create_avatar_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/tasks_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/rpm_creator_screen.dart';
import 'services/avatar_service.dart';
import 'services/task_service.dart';
import 'services/stats_service.dart';
import 'services/rpm_service.dart';
import 'theme/app_theme.dart';

void main() async {
  // Инициализация Flutter биндингов
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive для локального хранения
  await Hive.initFlutter();

  // Регистрация адаптеров для моделей
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(StatsModelAdapter());
  Hive.registerAdapter(TaskTypeAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(StatsHistoryAdapter());

  // Открытие боксов для хранения данных
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<StatsModel>('stats');

  runApp(const HabitRPGApp());
}

/// Главный виджет приложения
class HabitRPGApp extends StatelessWidget {
  const HabitRPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Провайдеры для управления состоянием
        ChangeNotifierProvider(create: (_) => AvatarService()),
        ChangeNotifierProvider(create: (_) => TaskService()),
        ChangeNotifierProvider(create: (_) => StatsService()),
        ChangeNotifierProvider(create: (_) => RPMService()),
      ],
      child: MaterialApp(
        title: 'Habit RPG',
        debugShowCheckedModeBanner: false,

        // Тема приложения
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Начальный маршрут
        initialRoute: AppRoutes.splash,

        // Маршруты приложения
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.createAvatar: (context) => const CreateAvatarScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.tasks: (context) => const TasksScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
          AppRoutes.rpmCreator: (context) => const RPMCreatorScreen(),
        },

        // Обработка неизвестных маршрутов
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          );
        },
      ),
    );
  }
}
