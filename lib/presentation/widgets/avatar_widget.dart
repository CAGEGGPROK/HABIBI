import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/character_avatar.dart';

/// Виджет для отображения аватара персонажа
class AvatarWidget extends StatelessWidget {
  final String? avatarPath;
  final double size;
  final double borderWidth;
  final int? level;
  final bool showLevel;
  final VoidCallback? onTap;
  
  const AvatarWidget({
    super.key,
    this.avatarPath,
    this.size = 100,
    this.borderWidth = 3,
    this.level,
    this.showLevel = true,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Внешнее свечение для высоких уровней
          if (level != null && level! >= 10)
            Container(
              width: size + 20,
              height: size + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getLevelGlowColor(),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          
          // Основной контейнер аватара
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getBorderColor(),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildAvatarImage(),
            ),
          ),
          
          // Уровень персонажа
          if (showLevel && level != null)
            Positioned(
              bottom: 0,
              right: size * 0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getLevelBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Ур. $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Индикатор онлайн (опционально)
          if (onTap != null)
            Positioned(
              top: size * 0.05,
              right: size * 0.05,
              child: Container(
                width: size * 0.15,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Построение изображения аватара
  Widget _buildAvatarImage() {
    if (avatarPath != null && File(avatarPath!).existsSync()) {
      return Image.file(
        File(avatarPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size),
      );
    }
    
    return _buildPlaceholder(size);
  }
  
  /// Заглушка для аватара
  static Widget _buildPlaceholder(double size) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.5,
        color: AppColors.textHint,
      ),
    );
  }
  
  /// Получение цвета границы в зависимости от уровня
  Color _getBorderColor() {
    if (level == null) return AppColors.primary;
    
    if (level! >= 50) return Colors.red; // Легендарный
    if (level! >= 30) return Colors.purple; // Эпический
    if (level! >= 20) return Colors.orange; // Редкий
    if (level! >= 10) return Colors.blue; // Необычный
    return AppColors.primary; // Обычный
  }
  
  /// Получение цвета свечения для высоких уровней
  Color _getLevelGlowColor() {
    if (level! >= 50) return Colors.red.withOpacity(0.5);
    if (level! >= 30) return Colors.purple.withOpacity(0.5);
    if (level! >= 20) return Colors.orange.withOpacity(0.5);
    return Colors.blue.withOpacity(0.5);
  }
  
  /// Получение цвета фона для плашки уровня
  Color _getLevelBackgroundColor() {
    if (level == null) return AppColors.primary;
    
    if (level! >= 50) return Colors.red;
    if (level! >= 30) return Colors.purple;
    if (level! >= 20) return Colors.orange;
    if (level! >= 10) return Colors.blue;
    return AppColors.primary;
  }
}