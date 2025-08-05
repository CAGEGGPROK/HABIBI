import 'package:flutter/material.dart';

/// Цветовая палитра приложения
/// Соответствует макету Figma
class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFF6B4EE6); // Фиолетовый - основной цвет
  static const Color primaryDark = Color(0xFF5038B8); // Темный фиолетовый
  static const Color primaryLight = Color(0xFF8B72FF); // Светлый фиолетовый
  
  // Акцентные цвета
  static const Color accent = Color(0xFFFF6B6B); // Красный - для важных действий
  static const Color accentLight = Color(0xFFFF8787); // Светлый красный
  
  // Цвета для статов персонажа
  static const Color healthColor = Color(0xFFFF6B6B); // Здоровье - красный
  static const Color expColor = Color(0xFF4ECDC4); // Опыт - бирюзовый
  static const Color incomeColor = Color(0xFFFFD93D); // Доход - желтый
  static const Color sportColor = Color(0xFF6BCF7F); // Спорт - зеленый
  static const Color loveColor = Color(0xFFFF6B9D); // Личная жизнь - розовый
  static const Color socialColor = Color(0xFF4E89FF); // Социальная жизнь - синий
  
  // Цвета для приоритетов задач
  static const Color highPriority = Color(0xFFFF6B6B); // Высокий приоритет
  static const Color mediumPriority = Color(0xFFFFD93D); // Средний приоритет
  static const Color lowPriority = Color(0xFF6BCF7F); // Низкий приоритет
  
  // Фоновые цвета
  static const Color background = Color(0xFFF7F9FC); // Основной фон
  static const Color surface = Color(0xFFFFFFFF); // Поверхность карточек
  static const Color surfaceVariant = Color(0xFFF0F3F8); // Альтернативная поверхность
  
  // Текстовые цвета
  static const Color textPrimary = Color(0xFF2D3142); // Основной текст
  static const Color textSecondary = Color(0xFF9094A6); // Второстепенный текст
  static const Color textHint = Color(0xFFBFC3D2); // Подсказки
  
  // Цвета состояний
  static const Color success = Color(0xFF6BCF7F); // Успех
  static const Color warning = Color(0xFFFFD93D); // Предупреждение
  static const Color error = Color(0xFFFF6B6B); // Ошибка
  static const Color info = Color(0xFF4E89FF); // Информация
  
  // Цвета теней
  static const Color shadow = Color(0x1A000000); // 10% черный
  static const Color shadowLight = Color(0x0D000000); // 5% черный
  
  // Градиенты для фонов
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7F9FC), Color(0xFFE8ECF4)],
  );
  
  // Градиенты для карточек задач
  static const LinearGradient taskCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FC)],
  );
  
  // Цвета для темной темы
  static const Color darkBackground = Color(0xFF1A1B2E); // Темный фон
  static const Color darkSurface = Color(0xFF2D3142); // Темная поверхность
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Светлый текст
  static const Color darkTextSecondary = Color(0xFFB8BCC8); // Второстепенный текст в темной теме
}