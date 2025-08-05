import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Виджет полоски статистики персонажа
class StatBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final bool showPercentage;
  final double height;
  
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.showPercentage = true,
    this.height = 24,
  });
  
  @override
  Widget build(BuildContext context) {
    // Ограничиваем значение от 0 до 100
    final clampedValue = value.clamp(0.0, 100.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с иконкой и процентом
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (showPercentage)
              Text(
                '${clampedValue.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getValueColor(clampedValue),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Полоска прогресса
        Stack(
          children: [
            // Фон полоски
            Container(
              height: height,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            
            // Анимированный прогресс
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: height,
              width: MediaQuery.of(context).size.width * (clampedValue / 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildProgressContent(clampedValue),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Содержимое прогресс-бара
  Widget _buildProgressContent(double value) {
    if (value < 20) return const SizedBox.shrink();
    
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка состояния
            Icon(
              _getStateIcon(value),
              size: height * 0.6,
              color: Colors.white.withOpacity(0.9),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Получение цвета для значения
  Color _getValueColor(double value) {
    if (value >= 80) return AppColors.success;
    if (value >= 60) return AppColors.sportColor;
    if (value >= 40) return AppColors.warning;
    if (value >= 20) return Colors.orange;
    return AppColors.error;
  }
  
  /// Получение иконки состояния
  IconData _getStateIcon(double value) {
    if (value >= 80) return Icons.sentiment_very_satisfied_rounded;
    if (value >= 60) return Icons.sentiment_satisfied_rounded;
    if (value >= 40) return Icons.sentiment_neutral_rounded;
    if (value >= 20) return Icons.sentiment_dissatisfied_rounded;
    return Icons.sentiment_very_dissatisfied_rounded;
  }
}