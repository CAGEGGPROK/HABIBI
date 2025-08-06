import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../screens/create_avatar_screen.dart';

/// Виджет для отображения реалистичного 3D персонажа
class Realistic3DCharacter extends StatelessWidget {
  final CharacterCustomization customization;
  final double size;
  final double rotationY;

  const Realistic3DCharacter({
    super.key,
    required this.customization,
    required this.size,
    this.rotationY = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.8,
      child: CustomPaint(
        painter: Realistic3DPainter(
          customization: customization,
          rotationY: rotationY,
        ),
      ),
    );
  }
}

/// Painter для рисования реалистичного 3D персонажа
class Realistic3DPainter extends CustomPainter {
  final CharacterCustomization customization;
  final double rotationY;

  Realistic3DPainter({
    required this.customization,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Расчет пропорций на основе кастомизации с 3D эффектами
    final headRadius = size.width * (0.15 + customization.headSize * 0.1);
    final bodyHeight = size.height * (0.3 + customization.height * 0.2);
    final bodyWidth = size.width * (0.3 + customization.bodyBuild * 0.3);
    final armLength = size.height * (0.25 + customization.armLength * 0.15);
    final legLength = size.height * (0.3 + customization.legLength * 0.15);
    final shoulderWidth = bodyWidth * (0.8 + customization.shoulderWidth * 0.4);

    // Центр персонажа
    final centerX = size.width / 2;
    final headCenterY = headRadius + 20;

    // Применяем 3D трансформацию
    final perspective = _applyPerspective(rotationY);

    // Рисуем тень
    _draw3DShadow(canvas, size, centerX, size.height - 20, perspective);

    // Рисуем ноги с 3D эффектом
    _draw3DLegs(canvas, paint, centerX, headCenterY + bodyHeight, legLength,
        bodyWidth * 0.3, perspective);

    // Рисуем обувь
    if (customization.shoes != 'Босиком') {
      _draw3DShoes(canvas, paint, centerX, headCenterY + bodyHeight + legLength,
          bodyWidth * 0.35, perspective);
    }

    // Рисуем тело с 3D эффектом
    _draw3DBody(canvas, paint, centerX, headCenterY + headRadius, bodyWidth,
        bodyHeight, shoulderWidth, perspective);

    // Рисуем руки с 3D эффектом
    _draw3DArms(canvas, paint, centerX, headCenterY + headRadius + 20,
        armLength, shoulderWidth, perspective);

    // Рисуем голову с 3D эффектом
    _draw3DHead(canvas, paint, centerX, headCenterY, headRadius, perspective);

    // Рисуем волосы с 3D эффектом
    _draw3DHair(canvas, paint, centerX, headCenterY, headRadius, perspective);

    // Рисуем лицо с 3D эффектом
    _draw3DFace(canvas, paint, centerX, headCenterY, headRadius, perspective);

    // Рисуем аксессуары с 3D эффектом
    _draw3DAccessories(
        canvas, paint, centerX, headCenterY, headRadius, size, perspective);
  }

  /// Применение 3D перспективы
  Map<String, double> _applyPerspective(double rotationY) {
    final cosY = math.cos(rotationY);
    final sinY = math.sin(rotationY);

    return {
      'scaleX': cosY.abs(),
      'offsetX': sinY * 20,
      'depth': cosY > 0 ? 1.0 : 0.7,
    };
  }

  /// Рисование 3D тени
  void _draw3DShadow(Canvas canvas, Size size, double centerX, double y,
      Map<String, double> perspective) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2 * perspective['depth']!)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + perspective['offsetX']!, y),
        width: size.width * 0.6 * perspective['scaleX']!,
        height: 25,
      ),
      shadowPaint,
    );
  }

  /// Рисование 3D головы
  void _draw3DHead(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    paint.color = customization.skinColor;

    // Основная форма головы с 3D эффектом
    final headWidth = radius * 1.8 * perspective['scaleX']!;
    final headHeight = radius * 2.2;

    // Добавляем градиент для объема
    paint.shader = RadialGradient(
      colors: [
        customization.skinColor,
        customization.skinColor.withOpacity(0.8),
        customization.skinColor.withOpacity(0.6),
      ],
      stops: const [0.0, 0.7, 1.0],
    ).createShader(Rect.fromCenter(
      center: Offset(centerX + perspective['offsetX']!, centerY),
      width: headWidth,
      height: headHeight,
    ));

    switch (customization.faceShape) {
      case 'Круглое':
        canvas.drawCircle(
          Offset(centerX + perspective['offsetX']!, centerY),
          radius * perspective['scaleX']!,
          paint,
        );
        break;
      case 'Квадратное':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX + perspective['offsetX']!, centerY),
              width: headWidth,
              height: headHeight,
            ),
            Radius.circular(radius * 0.3),
          ),
          paint,
        );
        break;
      case 'Овальное':
      default:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX + perspective['offsetX']!, centerY),
            width: headWidth,
            height: headHeight,
          ),
          paint,
        );
        break;
    }

    paint.shader = null;

    // 3D уши
    _draw3DEars(canvas, paint, centerX, centerY, radius, perspective);
  }

  /// Рисование 3D ушей
  void _draw3DEars(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    paint.color = customization.skinColor.withOpacity(0.9);

    // Левое ухо (видимость зависит от поворота)
    if (perspective['scaleX']! > 0.3) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
              centerX -
                  radius * 0.9 * perspective['scaleX']! +
                  perspective['offsetX']!,
              centerY),
          width: radius * 0.3 * perspective['scaleX']!,
          height: radius * 0.4,
        ),
        paint,
      );
    }

    // Правое ухо
    if (perspective['scaleX']! > -0.3) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
              centerX +
                  radius * 0.9 * perspective['scaleX']! +
                  perspective['offsetX']!,
              centerY),
          width: radius * 0.3 * perspective['scaleX']!,
          height: radius * 0.4,
        ),
        paint,
      );
    }
  }

  /// Рисование 3D тела
  void _draw3DBody(
      Canvas canvas,
      Paint paint,
      double centerX,
      double topY,
      double width,
      double height,
      double shoulderWidth,
      Map<String, double> perspective) {
    final bodyColor = _getClothingColor(customization.topClothing);

    // Создаем градиент для объема
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        bodyColor.withOpacity(0.7),
        bodyColor,
        bodyColor.withOpacity(0.8),
      ],
    ).createShader(Rect.fromLTWH(
      centerX - width / 2 + perspective['offsetX']!,
      topY,
      width * perspective['scaleX']!,
      height,
    ));

    final path = Path();
    final adjustedWidth = width * perspective['scaleX']!;
    final adjustedShoulderWidth = shoulderWidth * perspective['scaleX']!;
    final offsetX = perspective['offsetX']!;

    // Плечи
    path.moveTo(centerX - adjustedShoulderWidth / 2 + offsetX, topY);
    path.lineTo(centerX + adjustedShoulderWidth / 2 + offsetX, topY);

    // Туловище
    path.lineTo(centerX + adjustedWidth / 2 + offsetX, topY + height * 0.7);
    path.lineTo(centerX + adjustedWidth / 2 + offsetX, topY + height);
    path.lineTo(centerX - adjustedWidth / 2 + offsetX, topY + height);
    path.lineTo(centerX - adjustedWidth / 2 + offsetX, topY + height * 0.7);
    path.close();

    canvas.drawPath(path, paint);
    paint.shader = null;

    // Детали одежды с 3D эффектом
    _draw3DClothingDetails(
        canvas, paint, centerX, topY, width, height, perspective);
  }

  /// Рисование 3D рук
  void _draw3DArms(Canvas canvas, Paint paint, double centerX, double topY,
      double length, double shoulderWidth, Map<String, double> perspective) {
    paint.color = customization.skinColor;

    final adjustedShoulderWidth = shoulderWidth * perspective['scaleX']!;
    final offsetX = perspective['offsetX']!;

    // Левая рука
    final leftArmPath = Path();
    leftArmPath.moveTo(centerX - adjustedShoulderWidth / 2 + offsetX, topY);
    leftArmPath.lineTo(
        centerX -
            adjustedShoulderWidth / 2 -
            15 * perspective['scaleX']! +
            offsetX,
        topY + length * 0.6);
    leftArmPath.lineTo(
        centerX -
            adjustedShoulderWidth / 2 -
            10 * perspective['scaleX']! +
            offsetX,
        topY + length);
    leftArmPath.lineTo(
        centerX -
            adjustedShoulderWidth / 2 +
            10 * perspective['scaleX']! +
            offsetX,
        topY + length);
    leftArmPath.lineTo(
        centerX -
            adjustedShoulderWidth / 2 +
            15 * perspective['scaleX']! +
            offsetX,
        topY + length * 0.6);
    leftArmPath.close();

    // Добавляем градиент для объема рук
    paint.shader = LinearGradient(
      colors: [
        customization.skinColor,
        customization.skinColor.withOpacity(0.8),
      ],
    ).createShader(leftArmPath.getBounds());

    canvas.drawPath(leftArmPath, paint);

    // Правая рука
    final rightArmPath = Path();
    rightArmPath.moveTo(centerX + adjustedShoulderWidth / 2 + offsetX, topY);
    rightArmPath.lineTo(
        centerX +
            adjustedShoulderWidth / 2 +
            15 * perspective['scaleX']! +
            offsetX,
        topY + length * 0.6);
    rightArmPath.lineTo(
        centerX +
            adjustedShoulderWidth / 2 +
            10 * perspective['scaleX']! +
            offsetX,
        topY + length);
    rightArmPath.lineTo(
        centerX +
            adjustedShoulderWidth / 2 -
            10 * perspective['scaleX']! +
            offsetX,
        topY + length);
    rightArmPath.lineTo(
        centerX +
            adjustedShoulderWidth / 2 -
            15 * perspective['scaleX']! +
            offsetX,
        topY + length * 0.6);
    rightArmPath.close();

    paint.shader = LinearGradient(
      colors: [
        customization.skinColor.withOpacity(0.8),
        customization.skinColor,
      ],
    ).createShader(rightArmPath.getBounds());

    canvas.drawPath(rightArmPath, paint);
    paint.shader = null;

    // 3D кисти рук
    _draw3DHands(
        canvas, paint, centerX, topY, length, shoulderWidth, perspective);
  }

  /// Рисование 3D кистей рук
  void _draw3DHands(Canvas canvas, Paint paint, double centerX, double topY,
      double armLength, double shoulderWidth, Map<String, double> perspective) {
    paint.color = customization.skinColor;

    final adjustedShoulderWidth = shoulderWidth * perspective['scaleX']!;
    final offsetX = perspective['offsetX']!;

    // Левая кисть
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          centerX -
              adjustedShoulderWidth / 2 -
              5 * perspective['scaleX']! +
              offsetX,
          topY + armLength,
        ),
        width: 24 * perspective['scaleX']!,
        height: 20,
      ),
      paint,
    );

    // Правая кисть
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          centerX +
              adjustedShoulderWidth / 2 +
              5 * perspective['scaleX']! +
              offsetX,
          topY + armLength,
        ),
        width: 24 * perspective['scaleX']!,
        height: 20,
      ),
      paint,
    );

    // Добавляем пальцы для реалистичности
    _draw3DFingers(
        canvas, paint, centerX, topY, armLength, shoulderWidth, perspective);
  }

  /// Рисование 3D пальцев
  void _draw3DFingers(Canvas canvas, Paint paint, double centerX, double topY,
      double armLength, double shoulderWidth, Map<String, double> perspective) {
    paint.color = customization.skinColor.withOpacity(0.9);

    final adjustedShoulderWidth = shoulderWidth * perspective['scaleX']!;
    final offsetX = perspective['offsetX']!;
    final fingerLength = 8.0;

    // Пальцы левой руки
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              centerX -
                  adjustedShoulderWidth / 2 -
                  5 * perspective['scaleX']! +
                  offsetX +
                  (i - 1.5) * 3 * perspective['scaleX']!,
              topY + armLength + 10,
            ),
            width: 4 * perspective['scaleX']!,
            height: fingerLength,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }

    // Пальцы правой руки
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              centerX +
                  adjustedShoulderWidth / 2 +
                  5 * perspective['scaleX']! +
                  offsetX +
                  (i - 1.5) * 3 * perspective['scaleX']!,
              topY + armLength + 10,
            ),
            width: 4 * perspective['scaleX']!,
            height: fingerLength,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  /// Рисование 3D ног
  void _draw3DLegs(Canvas canvas, Paint paint, double centerX, double topY,
      double length, double width, Map<String, double> perspective) {
    final pantsColor = _getClothingColor(customization.bottomClothing);
    paint.color = pantsColor;

    final adjustedWidth = width * perspective['scaleX']!;
    final offsetX = perspective['offsetX']!;

    // Добавляем градиент для объема
    paint.shader = LinearGradient(
      colors: [
        pantsColor.withOpacity(0.8),
        pantsColor,
        pantsColor.withOpacity(0.9),
      ],
    ).createShader(Rect.fromLTWH(
      centerX - adjustedWidth * 2 + offsetX,
      topY,
      adjustedWidth * 4,
      length,
    ));

    // Левая нога
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - adjustedWidth + offsetX, topY + length / 2),
          width: adjustedWidth * 0.8,
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
          center: Offset(centerX + adjustedWidth + offsetX, topY + length / 2),
          width: adjustedWidth * 0.8,
          height: length,
        ),
        const Radius.circular(8),
      ),
      paint,
    );

    paint.shader = null;
  }

  /// Рисование 3D обуви
  void _draw3DShoes(Canvas canvas, Paint paint, double centerX, double topY,
      double width, Map<String, double> perspective) {
    paint.color = _getShoesColor();

    final adjustedWidth = width * perspective['scaleX']!;
    final offsetX = perspective['offsetX']!;

    // Добавляем градиент для объема обуви
    paint.shader = LinearGradient(
      colors: [
        _getShoesColor().withOpacity(0.7),
        _getShoesColor(),
        _getShoesColor().withOpacity(0.8),
      ],
    ).createShader(Rect.fromLTWH(
      centerX - adjustedWidth * 1.5 + offsetX,
      topY,
      adjustedWidth * 3,
      30,
    ));

    // Левая обувь
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - adjustedWidth + offsetX, topY + 15),
          width: adjustedWidth * 1.2,
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
          center: Offset(centerX + adjustedWidth + offsetX, topY + 15),
          width: adjustedWidth * 1.2,
          height: 30,
        ),
        const Radius.circular(15),
      ),
      paint,
    );

    paint.shader = null;
  }

  /// Рисование 3D волос
  void _draw3DHair(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    if (customization.hairStyle == 'Лысый') return;

    paint.color = customization.hairColor;
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    switch (customization.hairStyle) {
      case 'Короткая':
        _drawShort3DHair(canvas, paint, centerX, centerY, radius, perspective);
        break;
      case 'Средняя':
        _drawMediumRealisticHair(canvas, paint, centerX, centerY, radius);
        break;
      case 'Длинная':
        _drawLongRealisticHair(canvas, paint, centerX, centerY, radius);
        break;
      case 'Ирокез':
        _draw3DMohawk(canvas, paint, centerX, centerY, radius, perspective);
        break;
      case 'Кудрявая':
        _drawCurlyHair(canvas, paint, centerX, centerY, radius);
        break;
      default:
        _drawShort3DHair(canvas, paint, centerX, centerY, radius, perspective);
    }

    // Растительность на лице с 3D эффектом
    if (customization.facialHair != 'Нет') {
      _drawRealisticFacialHair(canvas, paint, centerX, centerY, radius);
    }
  }

  /// Рисование короткой 3D прически
  void _drawShort3DHair(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, Map<String, double> perspective) {
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    // Добавляем градиент для объема волос
    paint.shader = RadialGradient(
      colors: [
        customization.hairColor,
        customization.hairColor.withOpacity(0.8),
        customization.hairColor.withOpacity(0.6),
      ],
    ).createShader(Rect.fromCenter(
      center: Offset(centerX + offsetX, centerY - radius * 0.3),
      width: radius * 2.2 * scaleX,
      height: radius * 1.8,
    ));

    final path = Path();
    path.addArc(
      Rect.fromCenter(
        center: Offset(centerX + offsetX, centerY - radius * 0.3),
        width: radius * 2.2 * scaleX,
        height: radius * 1.8,
      ),
      3.14,
      3.14,
    );
    canvas.drawPath(path, paint);

    paint.shader = null;
  }

  /// Рисование средних волос
  void _drawMediumRealisticHair(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    // Реализация метода для средних волос
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
    canvas.drawPath(path, paint);
  }

  /// Рисование длинных волос
  void _drawLongRealisticHair(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    // Реализация метода для длинных волос
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

    // Добавляем длинные пряди
    path.moveTo(centerX - radius * 1.1, centerY);
    path.quadraticBezierTo(
      centerX - radius * 1.3,
      centerY + radius * 1.5,
      centerX - radius * 0.8,
      centerY + radius * 2.5,
    );

    canvas.drawPath(path, paint);
  }

  /// Рисование кудрявых волос
  void _drawCurlyHair(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    // Реализация метода для кудрявых волос
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 3.14 * 2;
      final x = centerX + math.cos(angle) * radius * 0.9;
      final y = centerY - radius * 0.3 + math.sin(angle) * radius * 0.3;

      canvas.drawCircle(Offset(x, y), radius * 0.2, paint);
    }
  }

  /// Рисование 3D ирокеза
  void _draw3DMohawk(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    // Добавляем градиент для объема
    paint.shader = LinearGradient(
      colors: [
        customization.hairColor.withOpacity(0.8),
        customization.hairColor,
        customization.hairColor.withOpacity(0.7),
      ],
    ).createShader(Rect.fromLTWH(
      centerX - radius * 0.3 + offsetX,
      centerY - radius * 1.5,
      radius * 0.6 * scaleX,
      radius * 0.8,
    ));

    final path = Path();
    path.moveTo(centerX - radius * 0.3 * scaleX + offsetX, centerY - radius);
    path.lineTo(centerX + offsetX, centerY - radius * 1.5);
    path.lineTo(centerX + radius * 0.3 * scaleX + offsetX, centerY - radius);
    path.quadraticBezierTo(
      centerX + offsetX,
      centerY - radius * 0.8,
      centerX - radius * 0.3 * scaleX + offsetX,
      centerY - radius,
    );

    canvas.drawPath(path, paint);
    paint.shader = null;
  }

  /// Рисование реалистичной растительности на лице
  void _drawRealisticFacialHair(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    paint.color = customization.hairColor.withOpacity(0.8);

    switch (customization.facialHair) {
      case 'Усы':
        // Рисуем усы с текстурой
        for (int i = 0; i < 20; i++) {
          final x = centerX - radius * 0.4 + (i / 20) * radius * 0.8;
          final y = centerY + radius * 0.3 + math.sin(i * 0.5) * 2;
          canvas.drawCircle(Offset(x, y), 1, paint);
        }
        break;
      case 'Борода':
      case 'Полная борода':
        // Рисуем бороду с текстурой
        for (int i = 0; i < 50; i++) {
          final angle = (i / 50) * 3.14;
          final x = centerX + math.cos(angle + 3.14) * radius * 0.6;
          final y = centerY + radius * 0.4 + math.sin(angle) * radius * 0.3;
          canvas.drawCircle(Offset(x, y), 1.5, paint);
        }
        break;
    }

    paint.style = PaintingStyle.fill;
  }

  /// Рисование 3D лица
  void _draw3DFace(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    // Глаза с 3D эффектом
    _draw3DEyes(canvas, paint, centerX, centerY, radius, perspective);

    // Нос с 3D эффектом
    _draw3DNose(canvas, paint, centerX, centerY, radius, perspective);

    // Рот с 3D эффектом
    _draw3DMouth(canvas, paint, centerX, centerY, radius, perspective);
  }

  /// Рисование 3D глаз
  void _draw3DEyes(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    final eyeY = centerY - radius * 0.1;
    final eyeDistance = radius * 0.35 * perspective['scaleX']!;
    final offsetX = perspective['offsetX']!;

    // Белки глаз с тенями
    paint.color = Colors.white;

    // Левый глаз
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - eyeDistance + offsetX, eyeY),
        width: radius * 0.3 * perspective['scaleX']!,
        height: radius * 0.2,
      ),
      paint,
    );

    // Правый глаз
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + eyeDistance + offsetX, eyeY),
        width: radius * 0.3 * perspective['scaleX']!,
        height: radius * 0.2,
      ),
      paint,
    );

    // Радужка с градиентом
    final eyeGradient = RadialGradient(
      colors: [
        customization.eyeColor,
        customization.eyeColor.withOpacity(0.8),
        customization.eyeColor.withOpacity(0.6),
      ],
    );

    paint.shader = eyeGradient.createShader(Rect.fromCircle(
      center: Offset(centerX - eyeDistance + offsetX, eyeY),
      radius: radius * 0.08,
    ));
    canvas.drawCircle(
        Offset(centerX - eyeDistance + offsetX, eyeY), radius * 0.08, paint);

    paint.shader = eyeGradient.createShader(Rect.fromCircle(
      center: Offset(centerX + eyeDistance + offsetX, eyeY),
      radius: radius * 0.08,
    ));
    canvas.drawCircle(
        Offset(centerX + eyeDistance + offsetX, eyeY), radius * 0.08, paint);

    paint.shader = null;

    // Зрачки
    paint.color = Colors.black;
    canvas.drawCircle(
        Offset(centerX - eyeDistance + offsetX, eyeY), radius * 0.04, paint);
    canvas.drawCircle(
        Offset(centerX + eyeDistance + offsetX, eyeY), radius * 0.04, paint);

    // Блики
    paint.color = Colors.white;
    canvas.drawCircle(Offset(centerX - eyeDistance + offsetX + 2, eyeY - 2),
        radius * 0.02, paint);
    canvas.drawCircle(Offset(centerX + eyeDistance + offsetX + 2, eyeY - 2),
        radius * 0.02, paint);
  }

  /// Рисование 3D носа
  void _draw3DNose(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    paint.color = customization.skinColor.withOpacity(0.8);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    switch (customization.noseShape) {
      case 'Прямой':
        canvas.drawLine(
          Offset(centerX + offsetX, centerY - radius * 0.05),
          Offset(centerX + offsetX, centerY + radius * 0.15),
          paint,
        );
        break;
      case 'Курносый':
        final path = Path();
        path.moveTo(centerX + offsetX, centerY - radius * 0.05);
        path.quadraticBezierTo(
          centerX - radius * 0.05 * scaleX + offsetX,
          centerY + radius * 0.1,
          centerX + offsetX,
          centerY + radius * 0.15,
        );
        canvas.drawPath(path, paint);
        break;
      default:
        canvas.drawLine(
          Offset(centerX + offsetX, centerY - radius * 0.05),
          Offset(centerX + offsetX, centerY + radius * 0.15),
          paint,
        );
    }

    paint.style = PaintingStyle.fill;
  }

  /// Рисование 3D рта
  void _draw3DMouth(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    final mouthY = centerY + radius * 0.35;
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    paint.color = const Color(0xFFE57373);

    switch (customization.lipsShape) {
      case 'Тонкие':
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(centerX + offsetX, mouthY),
            width: radius * 0.4 * scaleX,
            height: radius * 0.1,
          ),
          0,
          3.14,
          false,
          paint,
        );
        break;
      case 'Пухлые':
        paint.style = PaintingStyle.fill;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX + offsetX, mouthY),
            width: radius * 0.5 * scaleX,
            height: radius * 0.2,
          ),
          paint,
        );
        break;
      default:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 3;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(centerX + offsetX, mouthY),
            width: radius * 0.4 * scaleX,
            height: radius * 0.15,
          ),
          0,
          3.14,
          false,
          paint,
        );
    }

    paint.style = PaintingStyle.fill;
  }

  /// Рисование 3D деталей одежды
  void _draw3DClothingDetails(
      Canvas canvas,
      Paint paint,
      double centerX,
      double topY,
      double width,
      double height,
      Map<String, double> perspective) {
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    switch (customization.topClothing) {
      case 'Футболка':
        // V-образный вырез с тенью
        paint.color = customization.skinColor;
        final vPath = Path();
        vPath.moveTo(centerX - width * 0.15 * scaleX + offsetX, topY);
        vPath.lineTo(centerX + offsetX, topY + height * 0.15);
        vPath.lineTo(centerX + width * 0.15 * scaleX + offsetX, topY);
        canvas.drawPath(vPath, paint);
        break;
      case 'Рубашка':
        // Воротник с 3D эффектом
        paint.color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX + offsetX, topY),
              width: width * 0.4 * scaleX,
              height: 20,
            ),
            const Radius.circular(10),
          ),
          paint,
        );

        // Пуговицы с тенями
        paint.color = Colors.black;
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(centerX + offsetX, topY + 30 + i * 30),
            3,
            paint,
          );
          // Тень пуговицы
          paint.color = Colors.black.withOpacity(0.3);
          canvas.drawCircle(
            Offset(centerX + offsetX + 1, topY + 31 + i * 30),
            3,
            paint,
          );
          paint.color = Colors.black;
        }
        break;
    }
  }

  /// Рисование 3D аксессуаров
  void _draw3DAccessories(
      Canvas canvas,
      Paint paint,
      double centerX,
      double centerY,
      double radius,
      Size size,
      Map<String, double> perspective) {
    for (final accessory in customization.accessories) {
      switch (accessory) {
        case 'Очки':
          _draw3DGlasses(canvas, paint, centerX, centerY, radius, perspective);
          break;
        case 'Серьги':
          _draw3DEarrings(canvas, paint, centerX, centerY, radius);
          break;
        case 'Шляпа':
          _draw3DHat(canvas, paint, centerX, centerY, radius, perspective);
          break;
        case 'Ожерелье':
          _draw3DNecklace(
              canvas, paint, centerX, centerY + radius * 1.5, radius);
          break;
      }
    }
  }

  /// Рисование 3D очков
  void _draw3DGlasses(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, Map<String, double> perspective) {
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    // Левая линза
    canvas.drawCircle(
      Offset(
          centerX - radius * 0.35 * scaleX + offsetX, centerY - radius * 0.1),
      radius * 0.25,
      paint,
    );

    // Правая линза
    canvas.drawCircle(
      Offset(
          centerX + radius * 0.35 * scaleX + offsetX, centerY - radius * 0.1),
      radius * 0.25,
      paint,
    );

    // Перемычка
    canvas.drawLine(
      Offset(centerX - radius * 0.1 * scaleX + offsetX, centerY - radius * 0.1),
      Offset(centerX + radius * 0.1 * scaleX + offsetX, centerY - radius * 0.1),
      paint,
    );

    paint.style = PaintingStyle.fill;
  }

  /// Рисование 3D серег
  void _draw3DEarrings(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    paint.color = Colors.amber;

    // Добавляем блеск
    paint.shader = RadialGradient(
      colors: [Colors.amber, Colors.amber.shade700],
    ).createShader(Rect.fromCircle(
      center: Offset(centerX - radius * 0.9, centerY + radius * 0.1),
      radius: 5,
    ));

    canvas.drawCircle(
        Offset(centerX - radius * 0.9, centerY + radius * 0.1), 5, paint);
    canvas.drawCircle(
        Offset(centerX + radius * 0.9, centerY + radius * 0.1), 5, paint);

    paint.shader = null;
  }

  /// Рисование 3D шляпы
  void _draw3DHat(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, Map<String, double> perspective) {
    final offsetX = perspective['offsetX']!;
    final scaleX = perspective['scaleX']!;

    paint.color = Colors.brown.shade800;

    // Поля шляпы с перспективой
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + offsetX, centerY - radius * 1.2),
        width: radius * 3 * scaleX,
        height: radius * 0.8,
      ),
      paint,
    );

    // Тулья с градиентом
    paint.shader = LinearGradient(
      colors: [
        Colors.brown.shade800,
        Colors.brown.shade600,
      ],
    ).createShader(Rect.fromCenter(
      center: Offset(centerX + offsetX, centerY - radius * 1.4),
      width: radius * 1.8 * scaleX,
      height: radius * 0.8,
    ));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + offsetX, centerY - radius * 1.4),
          width: radius * 1.8 * scaleX,
          height: radius * 0.8,
        ),
        const Radius.circular(10),
      ),
      paint,
    );

    paint.shader = null;
  }

  /// Рисование 3D ожерелья
  void _draw3DNecklace(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    paint.color = Colors.amber;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;

    // Цепочка с бликами
    final path = Path();
    for (double i = 0; i <= 3.14; i += 0.2) {
      final x = centerX + math.cos(i + 3.14) * radius * 0.75;
      final y = centerY + math.sin(i) * radius * 0.3;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Кулон
    paint.style = PaintingStyle.fill;
    paint.shader = RadialGradient(
      colors: [Colors.amber, Colors.amber.shade700],
    ).createShader(Rect.fromCircle(
      center: Offset(centerX, centerY + radius * 0.3),
      radius: 8,
    ));

    canvas.drawCircle(Offset(centerX, centerY + radius * 0.3), 8, paint);

    paint.style = PaintingStyle.fill;
    paint.shader = null;
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
