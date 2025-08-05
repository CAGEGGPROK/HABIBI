import 'package:flutter/material.dart';
import '../screens/create_avatar_screen.dart';

/// Виджет для отображения кастомизируемого персонажа
class CustomizableCharacter extends StatelessWidget {
  final CharacterCustomization customization;
  final double size;
  
  const CustomizableCharacter({
    super.key,
    required this.customization,
    required this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.8,
      child: CustomPaint(
        painter: CharacterPainter(
          customization: customization,
        ),
      ),
    );
  }
}

/// Painter для рисования персонажа
class CharacterPainter extends CustomPainter {
  final CharacterCustomization customization;
  
  CharacterPainter({required this.customization});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Расчет пропорций на основе кастомизации
    final headRadius = size.width * (0.15 + customization.headSize * 0.1);
    final bodyHeight = size.height * (0.3 + customization.height * 0.2);
    final bodyWidth = size.width * (0.3 + customization.bodyBuild * 0.3);
    final armLength = size.height * (0.25 + customization.armLength * 0.15);
    final legLength = size.height * (0.3 + customization.legLength * 0.15);
    final shoulderWidth = bodyWidth * (0.8 + customization.shoulderWidth * 0.4);
    
    // Центр персонажа
    final centerX = size.width / 2;
    final headCenterY = headRadius + 20;
    
    // Рисуем тень
    _drawShadow(canvas, size, centerX, size.height - 20);
    
    // Рисуем ноги
    paint.color = _getClothingColor(customization.bottomClothing);
    _drawLegs(canvas, paint, centerX, headCenterY + bodyHeight, legLength, bodyWidth * 0.3);
    
    // Рисуем обувь
    if (customization.shoes != 'Босиком') {
      _drawShoes(canvas, paint, centerX, headCenterY + bodyHeight + legLength, bodyWidth * 0.35);
    }
    
    // Рисуем тело
    paint.color = _getClothingColor(customization.topClothing);
    _drawBody(canvas, paint, centerX, headCenterY + headRadius, bodyWidth, bodyHeight, shoulderWidth);
    
    // Рисуем руки
    paint.color = customization.skinColor;
    _drawArms(canvas, paint, centerX, headCenterY + headRadius + 20, armLength, shoulderWidth);
    
    // Рисуем голову
    _drawHead(canvas, paint, centerX, headCenterY, headRadius);
    
    // Рисуем волосы
    _drawHair(canvas, paint, centerX, headCenterY, headRadius);
    
    // Рисуем лицо
    _drawFace(canvas, paint, centerX, headCenterY, headRadius);
    
    // Рисуем аксессуары
    _drawAccessories(canvas, paint, centerX, headCenterY, headRadius, size);
  }
  
  /// Рисование тени
  void _drawShadow(Canvas canvas, Size size, double centerX, double y) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, y),
        width: size.width * 0.6,
        height: 20,
      ),
      shadowPaint,
    );
  }
  
  /// Рисование головы
  void _drawHead(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    paint.color = customization.skinColor;
    
    // Форма головы в зависимости от выбора
    switch (customization.faceShape) {
      case 'Круглое':
        canvas.drawCircle(Offset(centerX, centerY), radius, paint);
        break;
      case 'Квадратное':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(centerX, centerY), width: radius * 2, height: radius * 2),
            Radius.circular(radius * 0.3),
          ),
          paint,
        );
        break;
      case 'Овальное':
      default:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: radius * 1.8,
            height: radius * 2.2,
          ),
          paint,
        );
        break;
    }
    
    // Уши
    paint.color = customization.skinColor.withOpacity(0.9);
    canvas.drawCircle(Offset(centerX - radius * 0.9, centerY), radius * 0.2, paint);
    canvas.drawCircle(Offset(centerX + radius * 0.9, centerY), radius * 0.2, paint);
  }
  
  /// Рисование тела
  void _drawBody(Canvas canvas, Paint paint, double centerX, double topY, 
                 double width, double height, double shoulderWidth) {
    final path = Path();
    
    // Плечи
    path.moveTo(centerX - shoulderWidth / 2, topY);
    path.lineTo(centerX + shoulderWidth / 2, topY);
    
    // Туловище
    path.lineTo(centerX + width / 2, topY + height * 0.7);
    path.lineTo(centerX + width / 2, topY + height);
    path.lineTo(centerX - width / 2, topY + height);
    path.lineTo(centerX - width / 2, topY + height * 0.7);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Детали одежды
    _drawClothingDetails(canvas, paint, centerX, topY, width, height);
  }
  
  /// Рисование рук
  void _drawArms(Canvas canvas, Paint paint, double centerX, double topY, 
                 double length, double shoulderWidth) {
    paint.color = customization.skinColor;
    
    // Левая рука
    final leftArmPath = Path();
    leftArmPath.moveTo(centerX - shoulderWidth / 2, topY);
    leftArmPath.lineTo(centerX - shoulderWidth / 2 - 15, topY + length * 0.6);
    leftArmPath.lineTo(centerX - shoulderWidth / 2 - 10, topY + length);
    leftArmPath.lineTo(centerX - shoulderWidth / 2 + 10, topY + length);
    leftArmPath.lineTo(centerX - shoulderWidth / 2 + 15, topY + length * 0.6);
    leftArmPath.close();
    
    canvas.drawPath(leftArmPath, paint);
    
    // Правая рука
    final rightArmPath = Path();
    rightArmPath.moveTo(centerX + shoulderWidth / 2, topY);
    rightArmPath.lineTo(centerX + shoulderWidth / 2 + 15, topY + length * 0.6);
    rightArmPath.lineTo(centerX + shoulderWidth / 2 + 10, topY + length);
    rightArmPath.lineTo(centerX + shoulderWidth / 2 - 10, topY + length);
    rightArmPath.lineTo(centerX + shoulderWidth / 2 - 15, topY + length * 0.6);
    rightArmPath.close();
    
    canvas.drawPath(rightArmPath, paint);
    
    // Кисти рук
    canvas.drawCircle(
      Offset(centerX - shoulderWidth / 2 - 5, topY + length),
      12,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + shoulderWidth / 2 + 5, topY + length),
      12,
      paint,
    );
  }
  
  /// Рисование ног
  void _drawLegs(Canvas canvas, Paint paint, double centerX, double topY, 
                 double length, double width) {
    // Левая нога
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - width, topY + length / 2),
          width: width * 0.8,
          height: length,
        ),
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Правая нога
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + width, topY + length / 2),
          width: width * 0.8,
          height: length,
        ),
        const Radius.circular(8),
      ),
      paint,
    );
  }
  
  /// Рисование обуви
  void _drawShoes(Canvas canvas, Paint paint, double centerX, double topY, double width) {
    paint.color = _getShoesColor();
    
    // Левая обувь
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - width, topY + 15),
          width: width * 1.2,
          height: 30,
        ),
        const Radius.circular(15),
      ),
      paint,
    );
    
    // Правая обувь
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + width, topY + 15),
          width: width * 1.2,
          height: 30,
        ),
        const Radius.circular(15),
      ),
      paint,
    );
  }
  
  /// Рисование волос
  void _drawHair(Canvas canvas, Paint paint, double centerX, double centerY, double headRadius) {
    if (customization.hairStyle == 'Лысый') return;
    
    paint.color = customization.hairColor;
    
    switch (customization.hairStyle) {
      case 'Короткая':
        _drawShortHair(canvas, paint, centerX, centerY, headRadius);
        break;
      case 'Средняя':
        _drawMediumHair(canvas, paint, centerX, centerY, headRadius);
        break;
      case 'Длинная':
        _drawLongHair(canvas, paint, centerX, centerY, headRadius);
        break;
      case 'Ирокез':
        _drawMohawk(canvas, paint, centerX, centerY, headRadius);
        break;
      default:
        _drawShortHair(canvas, paint, centerX, centerY, headRadius);
    }
    
    // Растительность на лице
    if (customization.facialHair != 'Нет') {
      _drawFacialHair(canvas, paint, centerX, centerY, headRadius);
    }
  }
  
  /// Рисование короткой прически
  void _drawShortHair(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    final path = Path();
    path.addArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY - radius * 0.3),
        width: radius * 2.2,
        height: radius * 1.8,
      ),
      3.14,
      3.14,
    );
    canvas.drawPath(path, paint);
  }
  
  /// Рисование средней прически
  void _drawMediumHair(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    final path = Path();
    path.addArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY - radius * 0.2),
        width: radius * 2.4,
        height: radius * 2.2,
      ),
      3.14,
      3.14,
    );
    
    // Боковые пряди
    path.moveTo(centerX - radius, centerY);
    path.quadraticBezierTo(
      centerX - radius * 1.2, centerY + radius * 0.5,
      centerX - radius * 0.8, centerY + radius,
    );
    
    path.moveTo(centerX + radius, centerY);
    path.quadraticBezierTo(
      centerX + radius * 1.2, centerY + radius * 0.5,
      centerX + radius * 0.8, centerY + radius,
    );
    
    canvas.drawPath(path, paint);
  }
  
  /// Рисование длинной прически
  void _drawLongHair(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    final path = Path();
    path.addArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY - radius * 0.2),
        width: radius * 2.4,
        height: radius * 2.2,
      ),
      3.14,
      3.14,
    );
    
    // Длинные волосы
    path.moveTo(centerX - radius * 1.1, centerY);
    path.quadraticBezierTo(
      centerX - radius * 1.3, centerY + radius * 1.5,
      centerX - radius * 0.8, centerY + radius * 2.5,
    );
    
    path.moveTo(centerX + radius * 1.1, centerY);
    path.quadraticBezierTo(
      centerX + radius * 1.3, centerY + radius * 1.5,
      centerX + radius * 0.8, centerY + radius * 2.5,
    );
    
    canvas.drawPath(path, paint);
  }
  
  /// Рисование ирокеза
  void _drawMohawk(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    final path = Path();
    path.moveTo(centerX - radius * 0.3, centerY - radius);
    path.lineTo(centerX, centerY - radius * 1.5);
    path.lineTo(centerX + radius * 0.3, centerY - radius);
    path.quadraticBezierTo(
      centerX, centerY - radius * 0.8,
      centerX - radius * 0.3, centerY - radius,
    );
    
    canvas.drawPath(path, paint);
  }
  
  /// Рисование растительности на лице
  void _drawFacialHair(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    paint.color = customization.hairColor.withOpacity(0.8);
    
    switch (customization.facialHair) {
      case 'Усы':
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(centerX, centerY + radius * 0.3),
            width: radius * 0.8,
            height: radius * 0.3,
          ),
          0.2,
          2.7,
          false,
          paint..strokeWidth = 3..style = PaintingStyle.stroke,
        );
        break;
      case 'Борода':
        final beardPath = Path();
        beardPath.moveTo(centerX - radius * 0.5, centerY + radius * 0.4);
        beardPath.quadraticBezierTo(
          centerX, centerY + radius * 0.8,
          centerX + radius * 0.5, centerY + radius * 0.4,
        );
        canvas.drawPath(beardPath, paint..style = PaintingStyle.fill);
        break;
      case 'Полная борода':
        final fullBeardPath = Path();
        fullBeardPath.moveTo(centerX - radius * 0.7, centerY);
        fullBeardPath.quadraticBezierTo(
          centerX - radius * 0.8, centerY + radius * 0.6,
          centerX, centerY + radius * 0.9,
        );
        fullBeardPath.quadraticBezierTo(
          centerX + radius * 0.8, centerY + radius * 0.6,
          centerX + radius * 0.7, centerY,
        );
        canvas.drawPath(fullBeardPath, paint..style = PaintingStyle.fill);
        break;
    }
    
    paint.style = PaintingStyle.fill;
  }
  
  /// Рисование лица
  void _drawFace(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    // Глаза
    _drawEyes(canvas, paint, centerX, centerY, radius);
    
    // Нос
    _drawNose(canvas, paint, centerX, centerY, radius);
    
    // Рот
    _drawMouth(canvas, paint, centerX, centerY, radius);
  }
  
  /// Рисование глаз
  void _drawEyes(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    final eyeY = centerY - radius * 0.1;
    final eyeDistance = radius * 0.35;
    
    // Белки глаз
    paint.color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - eyeDistance, eyeY),
        width: radius * 0.3,
        height: radius * 0.2,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + eyeDistance, eyeY),
        width: radius * 0.3,
        height: radius * 0.2,
      ),
      paint,
    );
    
    // Радужка
    paint.color = customization.eyeColor;
    canvas.drawCircle(Offset(centerX - eyeDistance, eyeY), radius * 0.08, paint);
    canvas.drawCircle(Offset(centerX + eyeDistance, eyeY), radius * 0.08, paint);
    
    // Зрачки
    paint.color = Colors.black;
    canvas.drawCircle(Offset(centerX - eyeDistance, eyeY), radius * 0.04, paint);
    canvas.drawCircle(Offset(centerX + eyeDistance, eyeY), radius * 0.04, paint);
    
    // Блики
    paint.color = Colors.white;
    canvas.drawCircle(Offset(centerX - eyeDistance + 2, eyeY - 2), radius * 0.02, paint);
    canvas.drawCircle(Offset(centerX + eyeDistance + 2, eyeY - 2), radius * 0.02, paint);
  }
  
  /// Рисование носа
  void _drawNose(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    paint.color = customization.skinColor.withOpacity(0.8);
    
    switch (customization.noseShape) {
      case 'Прямой':
        canvas.drawLine(
          Offset(centerX, centerY - radius * 0.05),
          Offset(centerX, centerY + radius * 0.15),
          paint..strokeWidth = 2..style = PaintingStyle.stroke,
        );
        break;
      case 'Курносый':
        final path = Path();
        path.moveTo(centerX, centerY - radius * 0.05);
        path.quadraticBezierTo(
          centerX - radius * 0.05, centerY + radius * 0.1,
          centerX, centerY + radius * 0.15,
        );
        canvas.drawPath(path, paint..style = PaintingStyle.stroke);
        break;
      default:
        canvas.drawLine(
          Offset(centerX, centerY - radius * 0.05),
          Offset(centerX, centerY + radius * 0.15),
          paint..strokeWidth = 2..style = PaintingStyle.stroke,
        );
    }
    
    paint.style = PaintingStyle.fill;
  }
  
  /// Рисование рта
  void _drawMouth(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    final mouthY = centerY + radius * 0.35;
    
    paint.color = const Color(0xFFE57373);
    
    switch (customization.lipsShape) {
      case 'Тонкие':
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(centerX, mouthY),
            width: radius * 0.4,
            height: radius * 0.1,
          ),
          0,
          3.14,
          false,
          paint..strokeWidth = 2..style = PaintingStyle.stroke,
        );
        break;
      case 'Пухлые':
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX, mouthY),
            width: radius * 0.5,
            height: radius * 0.2,
          ),
          paint..style = PaintingStyle.fill,
        );
        break;
      default:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(centerX, mouthY),
            width: radius * 0.4,
            height: radius * 0.15,
          ),
          0,
          3.14,
          false,
          paint..strokeWidth = 3..style = PaintingStyle.stroke,
        );
    }
    
    paint.style = PaintingStyle.fill;
  }
  
  /// Рисование деталей одежды
  void _drawClothingDetails(Canvas canvas, Paint paint, double centerX, double topY, 
                           double width, double height) {
    switch (customization.topClothing) {
      case 'Футболка':
        // Рисуем V-образный вырез
        paint.color = customization.skinColor;
        final vPath = Path();
        vPath.moveTo(centerX - width * 0.15, topY);
        vPath.lineTo(centerX, topY + height * 0.15);
        vPath.lineTo(centerX + width * 0.15, topY);
        canvas.drawPath(vPath, paint);
        break;
      case 'Рубашка':
        // Рисуем воротник
        paint.color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX, topY),
              width: width * 0.4,
              height: 20,
            ),
            const Radius.circular(10),
          ),
          paint,
        );
        
        // Пуговицы
        paint.color = Colors.black;
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(centerX, topY + 30 + i * 30),
            3,
            paint,
          );
        }
        break;
    }
  }
  
  /// Рисование аксессуаров
  void _drawAccessories(Canvas canvas, Paint paint, double centerX, double centerY, 
                       double radius, Size size) {
    for (final accessory in customization.accessories) {
      switch (accessory) {
        case 'Очки':
          _drawGlasses(canvas, paint, centerX, centerY, radius);
          break;
        case 'Серьги':
          _drawEarrings(canvas, paint, centerX, centerY, radius);
          break;
        case 'Шляпа':
          _drawHat(canvas, paint, centerX, centerY, radius);
          break;
        case 'Ожерелье':
          _drawNecklace(canvas, paint, centerX, centerY + radius, radius);
          break;
      }
    }
  }
  
  /// Рисование очков
  void _drawGlasses(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    
    // Оправа
    canvas.drawCircle(Offset(centerX - radius * 0.35, centerY - radius * 0.1), radius * 0.25, paint);
    canvas.drawCircle(Offset(centerX + radius * 0.35, centerY - radius * 0.1), radius * 0.25, paint);
    
    // Перемычка
    canvas.drawLine(
      Offset(centerX - radius * 0.1, centerY - radius * 0.1),
      Offset(centerX + radius * 0.1, centerY - radius * 0.1),
      paint,
    );
    
    paint.style = PaintingStyle.fill;
  }
  
  /// Рисование серег
  void _drawEarrings(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    paint.color = Colors.amber;
    canvas.drawCircle(Offset(centerX - radius * 0.9, centerY + radius * 0.1), 5, paint);
    canvas.drawCircle(Offset(centerX + radius * 0.9, centerY + radius * 0.1), 5, paint);
  }
  
  /// Рисование шляпы
  void _drawHat(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    paint.color = Colors.brown.shade800;
    
    // Поля шляпы
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY - radius * 1.2),
        width: radius * 3,
        height: radius * 0.8,
      ),
      paint,
    );
    
    // Тулья
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY - radius * 1.4),
          width: radius * 1.8,
          height: radius * 0.8,
        ),
        const Radius.circular(10),
      ),
      paint,
    );
  }
  
  /// Рисование ожерелья
  void _drawNecklace(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    paint.color = Colors.amber;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: radius * 1.5,
        height: radius,
      ),
      0,
      3.14,
      false,
      paint,
    );
    
    paint.style = PaintingStyle.fill;
  }
  
  /// Получение цвета одежды
  Color _getClothingColor(String clothing) {
    switch (clothing) {
      case 'Футболка':
        return Colors.blue.shade600;
      case 'Рубашка':
        return Colors.grey.shade200;
      case 'Свитер':
        return Colors.green.shade700;
      case 'Худи':
        return Colors.grey.shade700;
      case 'Джинсы':
        return Colors.blue.shade900;
      case 'Брюки':
        return Colors.grey.shade800;
      case 'Шорты':
        return Colors.blue.shade700;
      case 'Юбка':
        return Colors.pink.shade400;
      case 'Спортивные штаны':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade500;
    }
  }
  
  /// Получение цвета обуви
  Color _getShoesColor() {
    switch (customization.shoes) {
      case 'Кроссовки':
        return Colors.white;
      case 'Ботинки':
        return Colors.brown.shade800;
      case 'Туфли':
        return Colors.black;
      case 'Сандалии':
        return Colors.brown.shade600;
      default:
        return Colors.grey.shade700;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}