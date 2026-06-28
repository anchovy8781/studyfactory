import 'package:flutter/material.dart';

import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Small inline stat badge (e.g. "🔥 14일 연속", "⭐ 1,250P").
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.size = StatChipSize.medium,
  });

  final String label;
  final IconData? icon;
  final String? emoji;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final StatChipSize size;

  /// Streak chip preset.
  const StatChip.streak({
    super.key,
    required int days,
    this.onTap,
    this.size = StatChipSize.medium,
  })  : label = '$days일 연속',
        emoji = '🔥',
        icon = null,
        color = AppColors.streakActive,
        backgroundColor = AppColors.warningLight;

  /// Points chip preset.
  const StatChip.points({
    super.key,
    required int points,
    this.onTap,
    this.size = StatChipSize.medium,
  })  : label = '${points}P',
        emoji = '⭐',
        icon = null,
        color = AppColors.warning,
        backgroundColor = AppColors.warningLight;

  /// Study time chip preset.
  const StatChip.studyTime({
    super.key,
    required String time,
    this.onTap,
    this.size = StatChipSize.medium,
  })  : label = time,
        icon = Icons.timer_outlined,
        emoji = null,
        color = AppColors.primary,
        backgroundColor = AppColors.primaryContainer;

  /// Rank chip preset.
  const StatChip.rank({
    super.key,
    required String rank,
    this.onTap,
    this.size = StatChipSize.medium,
  })  : label = rank,
        icon = Icons.emoji_events_outlined,
        emoji = null,
        color = AppColors.rankGold,
        backgroundColor = const Color(0xFFFFF8E1);

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    final chipBg = backgroundColor ?? AppColors.primaryContainer;

    final (double fontSize, double iconSize, EdgeInsets padding) =
        switch (size) {
      StatChipSize.small => (10.0, AppSizes.iconXs, const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      StatChipSize.medium => (12.0, AppSizes.iconSm, const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
      StatChipSize.large => (14.0, AppSizes.iconMd, const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
    };

    final chip = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: TextStyle(fontSize: iconSize)),
            const SizedBox(width: AppSizes.spaceXxs + 1),
          ] else if (icon != null) ...[
            Icon(icon, size: iconSize, color: chipColor),
            const SizedBox(width: AppSizes.spaceXxs + 1),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: chipColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;

    return GestureDetector(
      onTap: onTap,
      child: chip,
    );
  }
}

enum StatChipSize { small, medium, large }
