import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';

/// Animation state for the StudyVerse mascot dog.
enum CharacterMood {
  idle,
  happy,
  studying,
  cheering,
  sleeping,
}

/// The StudyVerse mascot — a cute Shiba Inu dog with "S" on its chest.
///
/// Fully drawn with [CustomPainter]; no external assets needed.
/// Supports mood-based animations via [AnimationController].
///
/// Usage:
/// ```dart
/// StudyCharacter(
///   size: 120,
///   mood: CharacterMood.happy,
///   animate: true,
/// )
/// ```
class StudyCharacter extends StatefulWidget {
  const StudyCharacter({
    super.key,
    this.size = AppSizes.characterMd,
    this.mood = CharacterMood.idle,
    this.animate = true,
    this.color,
  });

  final double size;
  final CharacterMood mood;
  final bool animate;
  final Color? color;

  @override
  State<StudyCharacter> createState() => _StudyCharacterState();
}

class _StudyCharacterState extends State<StudyCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _expressionController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _tailWagAnimation;
  late final Animation<double> _expressionAnimation;

  @override
  void initState() {
    super.initState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _expressionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _tailWagAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _expressionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expressionController,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.animate) {
      _idleController.repeat(reverse: true);
      _expressionController.forward();
    }
  }

  @override
  void didUpdateWidget(StudyCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood != oldWidget.mood) {
      _expressionController
        ..reset()
        ..forward();
    }
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _idleController.repeat(reverse: true);
      } else {
        _idleController.stop();
      }
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _expressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleController, _expressionController]),
      builder: (context, child) {
        final floatOffset = _floatAnimation.value * 6;
        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _DogPainter(
              mood: widget.mood,
              tailAngle: _tailWagAnimation.value,
              expressionProgress: _expressionAnimation.value,
              primaryColor: widget.color ?? AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painter
// ---------------------------------------------------------------------------

class _DogPainter extends CustomPainter {
  _DogPainter({
    required this.mood,
    required this.tailAngle,
    required this.expressionProgress,
    required this.primaryColor,
  });

  final CharacterMood mood;
  final double tailAngle; // -1.0 to 1.0
  final double expressionProgress; // 0.0 to 1.0
  final Color primaryColor;

  // Shiba Inu colour palette
  static const Color _furOrange = Color(0xFFD4712A);
  static const Color _furLight = Color(0xFFF5DEB3);
  static const Color _furDark = Color(0xFFB85C20);
  static const Color _noseDark = Color(0xFF2D1B00);
  static const Color _eyeDark = Color(0xFF1A1A1A);
  static const Color _white = Color(0xFFFFFFF0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Centred, sitting chibi pose. Draw order back-to-front.
    _drawTail(canvas, w, h);
    _drawBody(canvas, w, h);
    _drawPaws(canvas, w, h);
    _drawEars(canvas, w, h);
    _drawHead(canvas, w, h);
    _drawFace(canvas, w, h);
    _drawChestBadge(canvas, w, h);
  }

  void _drawTail(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = _furOrange
      ..style = PaintingStyle.fill;

    // Tail curls up behind the body on the right, gently wagging.
    final baseX = w * 0.70;
    final baseY = h * 0.80;
    final wag = tailAngle * 0.18;
    final tipX = w * (0.86 + wag);
    final tipY = h * 0.60;

    final path = Path()
      ..moveTo(baseX, baseY)
      ..quadraticBezierTo(w * 0.94, h * 0.78, tipX, tipY)
      ..quadraticBezierTo(w * 0.82, h * 0.66, baseX - w * 0.02, baseY - h * 0.06)
      ..close();
    canvas.drawPath(path, paint);

    // Lighter fluffy tip
    canvas.drawCircle(
      Offset(tipX, tipY),
      w * 0.055,
      Paint()..color = _furLight,
    );
  }

  void _drawBody(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = _furOrange
      ..style = PaintingStyle.fill;

    // Sitting body: a soft rounded triangle/teardrop, centred.
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.74),
        width: w * 0.52,
        height: h * 0.44,
      ),
      Radius.circular(w * 0.26),
    );
    canvas.drawRRect(bodyRect, paint);

    // Lighter belly patch
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.78),
          width: w * 0.30,
          height: h * 0.30,
        ),
        Radius.circular(w * 0.15),
      ),
      Paint()..color = _furLight,
    );
  }

  void _drawPaws(Canvas canvas, double w, double h) {
    final paint = Paint()..color = _furLight;
    // Two front paws resting at the bottom, symmetric.
    for (final dx in [0.38, 0.62]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * dx, h * 0.92),
          width: w * 0.16,
          height: h * 0.10,
        ),
        paint,
      );
      // toe lines
      final toe = Paint()
        ..color = _furDark.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.008
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(w * dx, h * 0.89),
        Offset(w * dx, h * 0.94),
        toe,
      );
    }
  }

  void _drawHead(Canvas canvas, double w, double h) {
    // Big chibi head, centred.
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.38),
      w * 0.30,
      Paint()..color = _furOrange,
    );

    // Lighter cheeks/muzzle area
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.46),
        width: w * 0.34,
        height: h * 0.20,
      ),
      Paint()..color = _furLight,
    );
  }

  void _drawEars(Canvas canvas, double w, double h) {
    final paint = Paint()..color = _furOrange;
    final innerPaint = Paint()..color = _furDark.withOpacity(0.45);

    // Rounded triangular ears, symmetric about the centre.
    void ear(double tipX, double tipY, double baseInX, double baseOutX,
        double baseY, double inTipX, double inTipY) {
      canvas.drawPath(
        Path()
          ..moveTo(w * baseInX, h * baseY)
          ..quadraticBezierTo(
              w * tipX, h * (tipY - 0.02), w * tipX, h * tipY)
          ..quadraticBezierTo(
              w * tipX, h * (tipY + 0.02), w * baseOutX, h * (baseY + 0.02))
          ..close(),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(w * (baseInX + 0.01), h * (baseY + 0.005))
          ..lineTo(w * inTipX, h * inTipY)
          ..lineTo(w * (baseOutX - 0.015), h * (baseY + 0.01))
          ..close(),
        innerPaint,
      );
    }

    // Left ear
    ear(0.20, 0.12, 0.30, 0.40, 0.24, 0.27, 0.17);
    // Right ear (mirrored)
    ear(0.80, 0.12, 0.70, 0.60, 0.24, 0.73, 0.17);
  }

  void _drawFace(Canvas canvas, double w, double h) {
    _drawEyes(canvas, w, h);

    // Nose
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.44),
        width: w * 0.09,
        height: h * 0.055,
      ),
      Paint()..color = _noseDark,
    );
    // Nose highlight
    canvas.drawCircle(
      Offset(w * 0.48, h * 0.43),
      w * 0.012,
      Paint()..color = _white.withOpacity(0.6),
    );

    _drawMouth(canvas, w, h);

    // Cheek blushes, symmetric
    final blush = Paint()..color = const Color(0xFFFF8A80).withOpacity(0.45);
    for (final dx in [0.32, 0.68]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * dx, h * 0.47),
          width: w * 0.09,
          height: h * 0.045,
        ),
        blush,
      );
    }
  }

  void _drawEyes(Canvas canvas, double w, double h) {
    const leftX = 0.385;
    const rightX = 0.615;
    const eyeY = 0.38;

    final eyePaint = Paint()..color = _eyeDark;
    final highlightPaint = Paint()..color = _white;

    switch (mood) {
      case CharacterMood.happy || CharacterMood.cheering:
        final happyPaint = Paint()
          ..color = _eyeDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.028
          ..strokeCap = StrokeCap.round;
        for (final dx in [leftX, rightX]) {
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(w * dx, h * eyeY),
              width: w * 0.11,
              height: h * 0.09,
            ),
            math.pi,
            math.pi,
            false,
            happyPaint,
          );
        }

      case CharacterMood.sleeping:
        final sleepPaint = Paint()
          ..color = _eyeDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.028
          ..strokeCap = StrokeCap.round;
        for (final dx in [leftX, rightX]) {
          canvas.drawLine(
            Offset(w * (dx - 0.04), h * eyeY),
            Offset(w * (dx + 0.04), h * eyeY),
            sleepPaint,
          );
        }

      case CharacterMood.idle || CharacterMood.studying:
        for (final dx in [leftX, rightX]) {
          canvas.drawCircle(Offset(w * dx, h * eyeY), w * 0.06, eyePaint);
          canvas.drawCircle(
            Offset(w * (dx - 0.02), h * (eyeY - 0.012)),
            w * 0.02,
            highlightPaint,
          );
        }
    }
  }

  void _drawMouth(Canvas canvas, double w, double h) {
    final mouthPaint = Paint()
      ..color = _noseDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;

    switch (mood) {
      case CharacterMood.happy || CharacterMood.cheering:
        // Open smile (two arcs meeting under the nose)
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.47),
            width: w * 0.18,
            height: h * 0.10,
          ),
          0,
          math.pi,
          false,
          mouthPaint,
        );
      case CharacterMood.sleeping:
        canvas.drawLine(
          Offset(w * 0.44, h * 0.49),
          Offset(w * 0.56, h * 0.49),
          mouthPaint,
        );
      case CharacterMood.idle || CharacterMood.studying:
        // Gentle "w" smile
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(w * 0.455, h * 0.475),
              width: w * 0.09,
              height: h * 0.05),
          0,
          math.pi,
          false,
          mouthPaint,
        );
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(w * 0.545, h * 0.475),
              width: w * 0.09,
              height: h * 0.05),
          0,
          math.pi,
          false,
          mouthPaint,
        );
    }
  }

  void _drawChestBadge(Canvas canvas, double w, double h) {
    final center = Offset(w * 0.5, h * 0.76);
    final radius = w * 0.10;

    canvas.drawCircle(center, radius, Paint()..color = primaryColor);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'S',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.13,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_DogPainter oldDelegate) =>
      oldDelegate.tailAngle != tailAngle ||
      oldDelegate.mood != mood ||
      oldDelegate.expressionProgress != expressionProgress;
}
