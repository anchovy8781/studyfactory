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

    // Draw order: tail → body → head → ears → face → chest badge
    _drawTail(canvas, w, h);
    _drawBody(canvas, w, h);
    _drawHead(canvas, w, h);
    _drawEars(canvas, w, h);
    _drawFace(canvas, w, h);
    _drawChestBadge(canvas, w, h);
  }

  void _drawTail(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = _furOrange
      ..style = PaintingStyle.fill;

    final cx = w * 0.78;
    final cy = h * 0.62;
    final angle = tailAngle * 0.5; // radians swing

    final path = Path();
    final tipX = cx + math.cos(angle) * w * 0.22;
    final tipY = cy - math.sin(angle).abs() * h * 0.18;
    path.moveTo(cx, cy);
    path.quadraticBezierTo(
      cx + w * 0.18,
      cy - h * 0.05,
      tipX,
      tipY,
    );
    path.quadraticBezierTo(
      tipX - w * 0.02,
      tipY + h * 0.06,
      cx + w * 0.02,
      cy + h * 0.04,
    );
    path.close();
    canvas.drawPath(path, paint);

    // Tail tip – lighter fluff
    final tipPaint = Paint()
      ..color = _furLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(tipX, tipY), w * 0.04, tipPaint);
  }

  void _drawBody(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = _furOrange
      ..style = PaintingStyle.fill;

    // Main body ellipse
    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.45, h * 0.68),
      width: w * 0.56,
      height: h * 0.38,
    );
    canvas.drawOval(bodyRect, paint);

    // Belly (lighter patch)
    final bellyPaint = Paint()
      ..color = _furLight
      ..style = PaintingStyle.fill;
    final bellyRect = Rect.fromCenter(
      center: Offset(w * 0.43, h * 0.72),
      width: w * 0.30,
      height: h * 0.24,
    );
    canvas.drawOval(bellyRect, bellyPaint);

    // Legs (four rounded rectangles)
    _drawLeg(canvas, w * 0.28, h * 0.80, w, h);
    _drawLeg(canvas, w * 0.42, h * 0.80, w, h);
    _drawLeg(canvas, w * 0.54, h * 0.80, w, h);
    _drawLeg(canvas, w * 0.63, h * 0.80, w, h);
  }

  void _drawLeg(Canvas canvas, double x, double y, double w, double h) {
    final paint = Paint()
      ..color = _furOrange
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, y + h * 0.05),
        width: w * 0.10,
        height: h * 0.14,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect, paint);

    // Paw
    final pawPaint = Paint()
      ..color = _furDark
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y + h * 0.13),
        width: w * 0.11,
        height: h * 0.05,
      ),
      pawPaint,
    );
  }

  void _drawHead(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = _furOrange
      ..style = PaintingStyle.fill;

    // Head circle
    canvas.drawCircle(Offset(w * 0.44, h * 0.38), w * 0.28, paint);

    // Muzzle
    final muzzlePaint = Paint()
      ..color = _furLight
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.44, h * 0.46),
        width: w * 0.24,
        height: h * 0.14,
      ),
      muzzlePaint,
    );
  }

  void _drawEars(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = _furOrange
      ..style = PaintingStyle.fill;
    final innerPaint = Paint()
      ..color = _furDark.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Left ear
    final leftEar = Path()
      ..moveTo(w * 0.22, h * 0.24)
      ..lineTo(w * 0.14, h * 0.10)
      ..lineTo(w * 0.30, h * 0.18)
      ..close();
    canvas.drawPath(leftEar, paint);

    // Left ear inner
    final leftInner = Path()
      ..moveTo(w * 0.22, h * 0.22)
      ..lineTo(w * 0.17, h * 0.13)
      ..lineTo(w * 0.28, h * 0.19)
      ..close();
    canvas.drawPath(leftInner, innerPaint);

    // Right ear
    final rightEar = Path()
      ..moveTo(w * 0.62, h * 0.24)
      ..lineTo(w * 0.72, h * 0.10)
      ..lineTo(w * 0.56, h * 0.18)
      ..close();
    canvas.drawPath(rightEar, paint);

    // Right ear inner
    final rightInner = Path()
      ..moveTo(w * 0.62, h * 0.22)
      ..lineTo(w * 0.68, h * 0.13)
      ..lineTo(w * 0.58, h * 0.19)
      ..close();
    canvas.drawPath(rightInner, innerPaint);
  }

  void _drawFace(Canvas canvas, double w, double h) {
    // Eyes
    _drawEyes(canvas, w, h);

    // Nose
    final nosePaint = Paint()
      ..color = _noseDark
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.44, h * 0.43),
        width: w * 0.08,
        height: h * 0.05,
      ),
      nosePaint,
    );

    // Nose highlight
    final highlightPaint = Paint()
      ..color = _white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.42, h * 0.42), w * 0.01, highlightPaint);

    // Mouth
    _drawMouth(canvas, w, h);

    // Cheek blushes
    final blushPaint = Paint()
      ..color = const Color(0xFFFF8A80).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.30, h * 0.46),
        width: w * 0.08,
        height: h * 0.04,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.58, h * 0.46),
        width: w * 0.08,
        height: h * 0.04,
      ),
      blushPaint,
    );
  }

  void _drawEyes(Canvas canvas, double w, double h) {
    final eyePaint = Paint()
      ..color = _eyeDark
      ..style = PaintingStyle.fill;
    final highlightPaint = Paint()
      ..color = _white
      ..style = PaintingStyle.fill;

    switch (mood) {
      case CharacterMood.happy || CharacterMood.cheering:
        // Happy ^^ eyes (arcs)
        final happyPaint = Paint()
          ..color = _eyeDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.025
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(w * 0.35, h * 0.37),
            width: w * 0.10,
            height: h * 0.08,
          ),
          math.pi,
          math.pi,
          false,
          happyPaint,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(w * 0.53, h * 0.37),
            width: w * 0.10,
            height: h * 0.08,
          ),
          math.pi,
          math.pi,
          false,
          happyPaint,
        );

      case CharacterMood.sleeping:
        // Zzz eyes (dashes)
        final sleepPaint = Paint()
          ..color = _eyeDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.025
          ..strokeCap = StrokeCap.round;
        canvas
          ..drawLine(
            Offset(w * 0.31, h * 0.37),
            Offset(w * 0.39, h * 0.37),
            sleepPaint,
          )
          ..drawLine(
            Offset(w * 0.49, h * 0.37),
            Offset(w * 0.57, h * 0.37),
            sleepPaint,
          );

      case CharacterMood.idle ||
            CharacterMood.studying:
        // Normal round eyes
        canvas
          ..drawCircle(Offset(w * 0.35, h * 0.37), w * 0.055, eyePaint)
          ..drawCircle(Offset(w * 0.53, h * 0.37), w * 0.055, eyePaint)
          // highlights
          ..drawCircle(Offset(w * 0.33, h * 0.36), w * 0.018, highlightPaint)
          ..drawCircle(Offset(w * 0.51, h * 0.36), w * 0.018, highlightPaint);
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
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(w * 0.44, h * 0.46),
            width: w * 0.16,
            height: h * 0.08,
          ),
          0,
          math.pi,
          false,
          mouthPaint,
        );
      case CharacterMood.sleeping:
        canvas.drawLine(
          Offset(w * 0.38, h * 0.48),
          Offset(w * 0.50, h * 0.48),
          mouthPaint,
        );
      case CharacterMood.idle || CharacterMood.studying:
        // Slight smile
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(w * 0.44, h * 0.47),
            width: w * 0.12,
            height: h * 0.06,
          ),
          0,
          math.pi,
          false,
          mouthPaint,
        );
    }
  }

  void _drawChestBadge(Canvas canvas, double w, double h) {
    // Badge background circle
    final badgePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.43, h * 0.68), w * 0.095, badgePaint);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015;
    canvas.drawCircle(Offset(w * 0.43, h * 0.68), w * 0.095, outlinePaint);

    // "S" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'S',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.12,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        w * 0.43 - textPainter.width / 2,
        h * 0.68 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_DogPainter oldDelegate) =>
      oldDelegate.tailAngle != tailAngle ||
      oldDelegate.mood != mood ||
      oldDelegate.expressionProgress != expressionProgress;
}
