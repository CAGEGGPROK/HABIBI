import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../../core/constants/app_colors.dart';

/// Виджет персонажа с телом и лицом пользователя
class CharacterAvatar extends StatelessWidget {
  final String? facePath;
  final Uint8List? faceBytes;
  final String gender;
  final double size;
  final int? level;
  final bool showLevel;
  
  const CharacterAvatar({
    super.key,
    this.facePath,
    this.faceBytes,
    this.gender = 'male',
    this.size = 200,
    this.level,
    this.showLevel = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.5, // Пропорции тела
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Тело персонажа
          _buildCharacterBody(),
          
          // Лицо пользователя
          if (facePath != null || faceBytes != null)
            Positioned(
              top: size * 0.1,
              child: _buildFace(),
            ),
          
          // Уровень
          if (showLevel && level != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getLevelColor(),
                  borderRadius: BorderRadius.circular(20),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Построение тела персонажа
  Widget _buildCharacterBody() {
    return Container(
      width: size,
      height: size * 1.5,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomPaint(
        painter: CharacterBodyPainter(
          gender: gender,
          level: level ?? 1,
        ),
      ),
    );
  }
  
  /// Построение лица
  Widget _buildFace() {
    final faceSize = size * 0.3;
    
    return Container(
      width: faceSize,
      height: faceSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildFaceImage(faceSize),
      ),
    );
  }
  
  Widget _buildFaceImage(double faceSize) {
    if (kIsWeb && faceBytes != null) {
      return Image.memory(
        faceBytes!,
        fit: BoxFit.cover,
        width: faceSize,
        height: faceSize,
      );
    } else if (facePath != null && !kIsWeb) {
      return Image.file(
        File(facePath!),
        fit: BoxFit.cover,
        width: faceSize,
        height: faceSize,
      );
    }
    
    return Container(
      color: AppColors.surfaceVariant,
      child: Icon(
        Icons.person_rounded,
        size: faceSize * 0.6,
        color: AppColors.textHint,
      ),
    );
  }
  
  Color _getLevelColor() {
    if (level == null) return AppColors.primary;
    if (level! >= 50) return Colors.red;
    if (level! >= 30) return Colors.purple;
    if (level! >= 20) return Colors.orange;
    if (level! >= 10) return Colors.blue;
    return AppColors.primary;
  }
}

/// Painter для рисования тела персонажа
class CharacterBodyPainter extends CustomPainter {
  final String gender;
  final int level;
  
  CharacterBodyPainter({
    required this.gender,
    required this.level,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Цвет одежды в зависимости от уровня
    if (level >= 50) {
      paint.color = Colors.red.shade400;
    } else if (level >= 30) {
      paint.color = Colors.purple.shade400;
    } else if (level >= 20) {
      paint.color = Colors.blue.shade400;
    } else if (level >= 10) {
      paint.color = Colors.green.shade400;
    } else {
      paint.color = Colors.grey.shade400;
    }
    
    // Рисуем простое тело
    if (gender == 'male') {
      _drawMaleBody(canvas, size, paint);
    } else {
      _drawFemaleBody(canvas, size, paint);
    }
  }
  
  void _drawMaleBody(Canvas canvas, Size size, Paint paint) {
    // Туловище
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.6, size.height * 0.4),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, paint);
    
    // Руки
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.35, size.width * 0.15, size.height * 0.3),
        const Radius.circular(8),
      ),
      paint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.8, size.height * 0.35, size.width * 0.15, size.height * 0.3),
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Ноги
    paint.color = Colors.blue.shade800; // Джинсы
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.25, size.height * 0.65, size.width * 0.2, size.height * 0.3),
        const Radius.circular(8),
      ),
      paint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.65, size.width * 0.2, size.height * 0.3),
        const Radius.circular(8),
      ),
      paint,
    );
  }
  
  void _drawFemaleBody(Canvas canvas, Size size, Paint paint) {
    // Платье
    final dressPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..close();
    
    canvas.drawPath(dressPath, paint);
    
    // Руки
    paint.color = const Color(0xFFFFDBB4); // Цвет кожи
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.35, size.width * 0.12, size.height * 0.25),
        const Radius.circular(8),
      ),
      paint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.78, size.height * 0.35, size.width * 0.12, size.height * 0.25),
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Ноги
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, size.height * 0.7, size.width * 0.15, size.height * 0.25),
        const Radius.circular(8),
      ),
      paint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.7, size.width * 0.15, size.height * 0.25),
        const Radius.circular(8),
      ),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}