import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';

/// Simple StudyVerse brand mark — a rounded gradient badge with an "S".
///
/// Replaces the former mascot character across the app. Pure brand element,
/// no animation or character styling.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 100, this.onSurface = false});

  final double size;

  /// When true, renders a light badge suitable for coloured backgrounds.
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: onSurface ? null : AppColors.primaryGradient,
        color: onSurface ? Colors.white : null,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: size * 0.52,
            fontWeight: FontWeight.w800,
            height: 1,
            color: onSurface ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}
