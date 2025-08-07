import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/create_avatar_screen.dart';
import '../../core/constants/app_colors.dart';

/// Виджет для отображения реалистичного 3D персонажа с анимацией
class Realistic3DCharacter extends StatefulWidget {
  final CharacterCustomization customization;
  final double size;
  final double rotationY;
  final bool enableAnimation;
  final VoidCallback? onTap;

  const Realistic3DCharacter({
    super.key,
    required this.customization,
    required this.size,
    this.rotationY = 0.0,
    this.enableAnimation = true,
    this.onTap,
  });

  @override
  State<Realistic3DCharacter> createState() => _Realistic3DCharacterState();
}

class _Realistic3DCharacterState extends State<Realistic3DCharacter>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Анимация дыхания
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // Анимация моргания
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableAnimation) {
      _breathingController.repeat(reverse: true);
      _startBlinking();
    }
  }

  void _startBlinking() {
    Future.delayed(Duration(seconds: 2 + math.Random().nextInt(3)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathingAnimation, _blinkAnimation]),
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Перспектива
              ..rotateY(widget.rotationY)
              ..scale(_breathingAnimation.value),
            child: SizedBox(
              width: widget.size,
              height: widget.size * 1.8,
              child: CustomPaint(
                painter: Realistic3DCharacterPainter(
                  customization: widget.customization,
                  blinkState: _blinkAnimation.value,
                  rotationY: widget.rotationY,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Painter для рисования реалистичного 3D персонажа
class Realistic3DCharacterPainter extends CustomPainter {
  final CharacterCustomization customization;
  final double blinkState;
  final double rotationY;

  Realistic3DCharacterPainter({
    required this.customization,
    required this.blinkState,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Центр персонажа
    final centerX = size.width / 2;
    final headRadius = size.width * (0.12 + customization.headSize * 0.08);
    final headCenterY = headRadius + 30;

    // Учитываем поворот для 3D эффекта
    final rotationFactor = math.cos(rotationY).abs();
    final depthOffset = math.sin(rotationY) * 10;

    // Рисуем тень под персонажем
    _drawCharacterShadow(canvas, size, centerX + depthOffset);

    // Рисуем персонажа слоями для 3D эффекта
    _drawCharacterLayers(canvas, size, centerX, headCenterY, headRadius,
        rotationFactor, depthOffset);
  }

  /// Рисование тени персонажа
  void _drawCharacterShadow(Canvas canvas, Size size, double centerX) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final shadowPath = Path();
    shadowPath.addOval(Rect.fromCenter(
      center: Offset(centerX, size.height - 20),
      width: size.width * 0.7,
      height: 30,
    ));

    canvas.drawPath(shadowPath, shadowPaint);
  }

  /// Рисование слоев персонажа
  void _drawCharacterLayers(
      Canvas canvas,
      Size size,
      double centerX,
      double headCenterY,
      double headRadius,
      double rotationFactor,
      double depthOffset) {
    final paint = Paint()..isAntiAlias = true;

    // Расчет размеров с учетом кастомизации
    final bodyWidth = size.width * (0.25 + customization.bodyBuild * 0.15);
    final bodyHeight = size.height * (0.25 + customization.height * 0.1);
    final armLength = size.height * (0.2 + customization.armLength * 0.1);
    final legLength = size.height * (0.25 + customization.legLength * 0.1);
    final shoulderWidth = bodyWidth * (0.9 + customization.shoulderWidth * 0.3);

    // 1. Задние элементы (дальше от камеры)
    if (rotationY > 0) {
      _drawBackElements(canvas, paint, centerX, headCenterY, headRadius,
          depthOffset, rotationFactor);
    }

    // 2. Ноги
    _drawLegs(canvas, paint, centerX + depthOffset, headCenterY + bodyHeight,
        legLength, bodyWidth * 0.25, rotationFactor);

    // 3. Обувь
    _drawShoes(canvas, paint, centerX + depthOffset,
        headCenterY + bodyHeight + legLength, bodyWidth * 0.3, rotationFactor);

    // 4. Тело
    _drawRealistic3DBody(
        canvas,
        paint,
        centerX + depthOffset,
        headCenterY + headRadius,
        bodyWidth,
        bodyHeight,
        shoulderWidth,
        rotationFactor);

    // 5. Руки
    _drawRealistic3DArms(
        canvas,
        paint,
        centerX + depthOffset,
        headCenterY + headRadius + 15,
        armLength,
        shoulderWidth,
        rotationFactor);

    // 6. Голова
    _drawRealistic3DHead(canvas, paint, centerX + depthOffset, headCenterY,
        headRadius, rotationFactor);

    // 7. Волосы
    _drawRealistic3DHair(canvas, paint, centerX + depthOffset, headCenterY,
        headRadius, rotationFactor);

    // 8. Лицо
    _drawRealistic3DFace(canvas, paint, centerX + depthOffset, headCenterY,
        headRadius, rotationFactor);

    // 9. Передние элементы (ближе к камере)
    if (rotationY <= 0) {
      _drawFrontElements(canvas, paint, centerX, headCenterY, headRadius,
          depthOffset, rotationFactor);
    }

    // 10. Аксессуары
    _drawRealistic3DAccessories(canvas, paint, centerX + depthOffset,
        headCenterY, headRadius, rotationFactor);
  }

  /// Рисование задних элементов
  void _drawBackElements(
      Canvas canvas,
      Paint paint,
      double centerX,
      double headCenterY,
      double headRadius,
      double depthOffset,
      double rotationFactor) {
    // Задняя часть волос, одежды и т.д.
    if (customization.hairStyle == 'Длинная') {
      paint.color = customization.hairColor.withOpacity(0.7);
      final backHairPath = Path();
      backHairPath.moveTo(centerX - headRadius * 0.8, headCenterY);
      backHairPath.quadraticBezierTo(
        centerX - headRadius * 1.2 - depthOffset * 0.5,
        headCenterY + headRadius * 2,
        centerX - headRadius * 0.6,
        headCenterY + headRadius * 3,
      );
      canvas.drawPath(backHairPath, paint);
    }
  }

  /// Рисование передних элементов
  void _drawFrontElements(
      Canvas canvas,
      Paint paint,
      double centerX,
      double headCenterY,
      double headRadius,
      double depthOffset,
      double rotationFactor) {
    // Передние аксессуары, детали одежды
  }

  /// Рисование реалистичного 3D тела
  void _drawRealistic3DBody(
      Canvas canvas,
      Paint paint,
      double centerX,
      double topY,
      double width,
      double height,
      double shoulderWidth,
      double rotationFactor) {
    paint.color = _getClothingColor(customization.topClothing);

    // Создаем 3D эффект для торса
    final bodyPath = Path();

    // Плечи
    bodyPath.moveTo(centerX - shoulderWidth / 2 * rotationFactor, topY);
    bodyPath.lineTo(centerX + shoulderWidth / 2 * rotationFactor, topY);

    // Боковые стороны с 3D эффектом
    bodyPath.lineTo(centerX + width / 2 * rotationFactor, topY + height * 0.7);
    bodyPath.lineTo(centerX + width / 2 * rotationFactor, topY + height);
    bodyPath.lineTo(centerX - width / 2 * rotationFactor, topY + height);
    bodyPath.lineTo(centerX - width / 2 * rotationFactor, topY + height * 0.7);
    bodyPath.close();

    // Градиент для объема
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        _getClothingColor(customization.topClothing).withOpacity(0.8),
        _getClothingColor(customization.topClothing),
        _getClothingColor(customization.topClothing).withOpacity(0.9),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(
      centerX - shoulderWidth / 2,
      topY,
      shoulderWidth,
      height,
    ));

    canvas.drawPath(bodyPath, paint);
    paint.shader = null;

    // Детали одежды
    _drawClothingDetails3D(
        canvas, paint, centerX, topY, width, height, rotationFactor);
  }

  /// Рисование реалистичных 3D рук
  void _drawRealistic3DArms(Canvas canvas, Paint paint, double centerX,
      double topY, double length, double shoulderWidth, double rotationFactor) {
    paint.color = customization.skinColor;

    final armWidth = 15 * rotationFactor;

    // Левая рука
    final leftArmRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          centerX - shoulderWidth / 2 * rotationFactor - armWidth / 2,
          topY + length / 2,
        ),
        width: armWidth,
        height: length,
      ),
      Radius.circular(armWidth / 2),
    );

    // Правая рука
    final rightArmRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          centerX + shoulderWidth / 2 * rotationFactor + armWidth / 2,
          topY + length / 2,
        ),
        width: armWidth,
        height: length,
      ),
      Radius.circular(armWidth / 2),
    );

    canvas.drawRRect(leftArmRect, paint);
    canvas.drawRRect(rightArmRect, paint);

    // Кисти рук
    canvas.drawCircle(
      Offset(centerX - shoulderWidth / 2 * rotationFactor - armWidth / 2,
          topY + length),
      armWidth * 0.7,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + shoulderWidth / 2 * rotationFactor + armWidth / 2,
          topY + length),
      armWidth * 0.7,
      paint,
    );
  }

  /// Рисование реалистичной 3D головы
  void _drawRealistic3DHead(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    paint.color = customization.skinColor;

    // Основная форма головы с учетом поворота
    final headWidth = radius * 2 * rotationFactor;
    final headHeight = radius * 2.2;

    switch (customization.faceShape) {
      case 'Круглое':
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: headWidth,
            height: headHeight,
          ),
          paint,
        );
        break;
      case 'Квадратное':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: headWidth,
              height: headHeight,
            ),
            Radius.circular(radius * 0.3),
          ),
          paint,
        );
        break;
      default: // Овальное
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: headWidth * 0.9,
            height: headHeight,
          ),
          paint,
        );
    }

    // Уши с учетом поворота
    if (rotationFactor > 0.3) {
      final earRadius = radius * 0.15;
      canvas.drawCircle(
        Offset(centerX - radius * 0.85 * rotationFactor, centerY),
        earRadius,
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + radius * 0.85 * rotationFactor, centerY),
        earRadius,
        paint,
      );
    }
  }

  /// Рисование реалистичных 3D волос
  void _drawRealistic3DHair(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    if (customization.hairStyle == 'Лысый') return;

    paint.color = customization.hairColor;

    final hairPath = Path();

    switch (customization.hairStyle) {
      case 'Короткая':
        hairPath.addArc(
          Rect.fromCenter(
            center: Offset(centerX, centerY - radius * 0.2),
            width: radius * 2.2 * rotationFactor,
            height: radius * 1.6,
          ),
          math.pi,
          math.pi,
        );
        break;

      case 'Средняя':
        hairPath.addArc(
          Rect.fromCenter(
            center: Offset(centerX, centerY - radius * 0.1),
            width: radius * 2.4 * rotationFactor,
            height: radius * 2.0,
          ),
          math.pi,
          math.pi,
        );
        break;

      case 'Длинная':
        hairPath.addArc(
          Rect.fromCenter(
            center: Offset(centerX, centerY - radius * 0.1),
            width: radius * 2.4 * rotationFactor,
            height: radius * 2.0,
          ),
          math.pi,
          math.pi,
        );

        // Длинные пряди
        hairPath.moveTo(centerX - radius * rotationFactor, centerY);
        hairPath.quadraticBezierTo(
          centerX - radius * 1.2 * rotationFactor,
          centerY + radius * 1.5,
          centerX - radius * 0.8 * rotationFactor,
          centerY + radius * 2.5,
        );

        hairPath.moveTo(centerX + radius * rotationFactor, centerY);
        hairPath.quadraticBezierTo(
          centerX + radius * 1.2 * rotationFactor,
          centerY + radius * 1.5,
          centerX + radius * 0.8 * rotationFactor,
          centerY + radius * 2.5,
        );
        break;
    }

    canvas.drawPath(hairPath, paint);

    // Растительность на лице
    if (customization.facialHair != 'Нет') {
      _drawFacialHair3D(
          canvas, paint, centerX, centerY, radius, rotationFactor);
    }
  }

  /// Рисование реалистичного 3D лица
  void _drawRealistic3DFace(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    // Глаза
    _drawRealistic3DEyes(
        canvas, paint, centerX, centerY, radius, rotationFactor);

    // Нос
    _drawRealistic3DNose(
        canvas, paint, centerX, centerY, radius, rotationFactor);

    // Рот
    _drawRealistic3DMouth(
        canvas, paint, centerX, centerY, radius, rotationFactor);

    // Брови
    _drawEyebrows(canvas, paint, centerX, centerY, radius, rotationFactor);
  }

  /// Рисование реалистичных 3D глаз
  void _drawRealistic3DEyes(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    final eyeY = centerY - radius * 0.1;
    final eyeDistance = radius * 0.35 * rotationFactor;
    final eyeWidth = radius * 0.25 * rotationFactor;
    final eyeHeight = radius * 0.15 * blinkState;

    // Белки глаз
    paint.color = Colors.white;

    // Левый глаз
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - eyeDistance, eyeY),
        width: eyeWidth,
        height: eyeHeight,
      ),
      paint,
    );

    // Правый глаз
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + eyeDistance, eyeY),
        width: eyeWidth,
        height: eyeHeight,
      ),
      paint,
    );

    if (blinkState > 0.3) {
      // Рисуем детали глаз только если не моргаем
      // Радужка
      paint.color = customization.eyeColor;
      final irisRadius = radius * 0.06 * blinkState;

      canvas.drawCircle(
        Offset(centerX - eyeDistance, eyeY),
        irisRadius,
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + eyeDistance, eyeY),
        irisRadius,
        paint,
      );

      // Зрачки
      paint.color = Colors.black;
      final pupilRadius = radius * 0.03 * blinkState;

      canvas.drawCircle(
        Offset(centerX - eyeDistance, eyeY),
        pupilRadius,
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + eyeDistance, eyeY),
        pupilRadius,
        paint,
      );

      // Блики
      paint.color = Colors.white;
      final highlightRadius = radius * 0.015 * blinkState;

      canvas.drawCircle(
        Offset(centerX - eyeDistance + 2, eyeY - 2),
        highlightRadius,
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + eyeDistance + 2, eyeY - 2),
        highlightRadius,
        paint,
      );
    }
  }

  /// Остальные методы рисования лица...
  void _drawRealistic3DNose(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    paint.color = customization.skinColor.withOpacity(0.8);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    final nosePath = Path();
    nosePath.moveTo(centerX, centerY - radius * 0.05);
    nosePath.lineTo(centerX + (2 * rotationFactor), centerY + radius * 0.15);

    canvas.drawPath(nosePath, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawRealistic3DMouth(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    final mouthY = centerY + radius * 0.35;
    paint.color = const Color(0xFFE57373);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, mouthY),
        width: radius * 0.4 * rotationFactor,
        height: radius * 0.15,
      ),
      0,
      math.pi,
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    paint.style = PaintingStyle.fill;
  }

  void _drawEyebrows(Canvas canvas, Paint paint, double centerX, double centerY,
      double radius, double rotationFactor) {
    paint.color = customization.hairColor.withOpacity(0.8);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    final eyebrowY = centerY - radius * 0.25;
    final eyebrowDistance = radius * 0.35 * rotationFactor;

    // Левая бровь
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX - eyebrowDistance, eyebrowY),
        width: radius * 0.3 * rotationFactor,
        height: radius * 0.1,
      ),
      0.2,
      2.7,
      false,
      paint,
    );

    // Правая бровь
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX + eyebrowDistance, eyebrowY),
        width: radius * 0.3 * rotationFactor,
        height: radius * 0.1,
      ),
      0.2,
      2.7,
      false,
      paint,
    );

    paint.style = PaintingStyle.fill;
  }

  /// Остальные вспомогательные методы...
  void _drawLegs(Canvas canvas, Paint paint, double centerX, double topY,
      double length, double width, double rotationFactor) {
    paint.color = _getClothingColor(customization.bottomClothing);

    final legWidth = width * rotationFactor;

    // Левая нога
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - width, topY + length / 2),
          width: legWidth,
          height: length,
        ),
        Radius.circular(legWidth / 2),
      ),
      paint,
    );

    // Правая нога
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + width, topY + length / 2),
          width: legWidth,
          height: length,
        ),
        Radius.circular(legWidth / 2),
      ),
      paint,
    );
  }

  void _drawShoes(Canvas canvas, Paint paint, double centerX, double topY,
      double width, double rotationFactor) {
    paint.color = _getShoesColor();

    final shoeWidth = width * 1.2 * rotationFactor;

    // Левая обувь
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - width, topY + 15),
          width: shoeWidth,
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
          width: shoeWidth,
          height: 30,
        ),
        const Radius.circular(15),
      ),
      paint,
    );
  }

  void _drawClothingDetails3D(Canvas canvas, Paint paint, double centerX,
      double topY, double width, double height, double rotationFactor) {
    // Добавляем детали одежды с учетом 3D поворота
    switch (customization.topClothing) {
      case 'Рубашка':
        // Воротник
        paint.color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX, topY),
              width: width * 0.4 * rotationFactor,
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

  void _drawFacialHair3D(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    paint.color = customization.hairColor.withOpacity(0.8);

    switch (customization.facialHair) {
      case 'Усы':
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(centerX, centerY + radius * 0.3),
            width: radius * 0.8 * rotationFactor,
            height: radius * 0.3,
          ),
          0.2,
          2.7,
          false,
          paint
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
        break;

      case 'Борода':
        final beardPath = Path();
        beardPath.moveTo(
            centerX - radius * 0.5 * rotationFactor, centerY + radius * 0.4);
        beardPath.quadraticBezierTo(
          centerX,
          centerY + radius * 0.8,
          centerX + radius * 0.5 * rotationFactor,
          centerY + radius * 0.4,
        );
        canvas.drawPath(beardPath, paint..style = PaintingStyle.fill);
        break;
    }

    paint.style = PaintingStyle.fill;
  }

  void _drawRealistic3DAccessories(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    for (final accessory in customization.accessories) {
      switch (accessory) {
        case 'Очки':
          _drawGlasses3D(
              canvas, paint, centerX, centerY, radius, rotationFactor);
          break;
        case 'Серьги':
          _drawEarrings3D(
              canvas, paint, centerX, centerY, radius, rotationFactor);
          break;
      }
    }
  }

  void _drawGlasses3D(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    final eyeDistance = radius * 0.35 * rotationFactor;
    final lensRadius = radius * 0.2 * rotationFactor;

    // Оправа
    canvas.drawCircle(Offset(centerX - eyeDistance, centerY - radius * 0.1),
        lensRadius, paint);
    canvas.drawCircle(Offset(centerX + eyeDistance, centerY - radius * 0.1),
        lensRadius, paint);

    // Перемычка
    canvas.drawLine(
      Offset(centerX - radius * 0.1 * rotationFactor, centerY - radius * 0.1),
      Offset(centerX + radius * 0.1 * rotationFactor, centerY - radius * 0.1),
      paint,
    );

    paint.style = PaintingStyle.fill;
  }

  void _drawEarrings3D(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius, double rotationFactor) {
    paint.color = Colors.amber;

    if (rotationFactor > 0.3) {
      canvas.drawCircle(
        Offset(centerX - radius * 0.9 * rotationFactor, centerY + radius * 0.1),
        5,
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + radius * 0.9 * rotationFactor, centerY + radius * 0.1),
        5,
        paint,
      );
    }
  }

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
