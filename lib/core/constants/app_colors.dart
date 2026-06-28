import 'package:flutter/material.dart';

/// StudyVerse brand color system.
/// Primary palette uses deep blue with warm orange accent.
abstract final class AppColors {
  // ── Primary palette ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryContainer = Color(0xFFD6E4FF);

  // ── Accent / secondary ─────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFFD5C2);
  static const Color accentDark = Color(0xFFD94F1E);

  // ── Semantic colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFB300);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ── Background (light mode) ────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4FF);
  static const Color surfaceElevated = Color(0xFFECF2FF);

  // ── Background (dark mode) ─────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color surfaceVariantDark = Color(0xFF21262D);
  static const Color surfaceElevatedDark = Color(0xFF30363D);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ── Text (dark mode) ──────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color textHintDark = Color(0xFF6E7681);

  // ── Border / Divider ──────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF30363D);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color dividerDark = Color(0xFF21262D);

  // ── Gamification / Rank colors ────────────────────────────────────────────
  static const Color rankBronze = Color(0xFFCD7F32);
  static const Color rankSilver = Color(0xFFC0C0C0);
  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankDiamond = Color(0xFF00BCD4);
  static const Color rankMaster = Color(0xFF9C27B0);

  // ── Subject tag colors ────────────────────────────────────────────────────
  static const Color subjectMath = Color(0xFF3F51B5);
  static const Color subjectScience = Color(0xFF00897B);
  static const Color subjectEnglish = Color(0xFFE91E63);
  static const Color subjectHistory = Color(0xFF795548);
  static const Color subjectArt = Color(0xFFFF5722);
  static const Color subjectMusic = Color(0xFF9C27B0);

  // ── Study streak / timer ──────────────────────────────────────────────────
  static const Color streakActive = Color(0xFFFF6B35);
  static const Color streakInactive = Color(0xFFE5E7EB);
  static const Color timerBackground = Color(0xFF0D1117);
  static const Color timerText = Color(0xFF64B5F6);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient studyGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient timerGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0x661A73E8), Color(0x001A73E8)],
    radius: 0.8,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1A1A2E).withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF1A1A2E).withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];
}
