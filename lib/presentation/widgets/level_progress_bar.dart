import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LevelProgressBar extends StatelessWidget {
  final int level;
  final int currentExp;
  final int expToNextLevel;

  const LevelProgressBar({
    super.key,
    required this.level,
    required this.currentExp,
    required this.expToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentExp / expToNextLevel;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Уровень $level',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$currentExp / $expToNextLevel XP',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.expColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}