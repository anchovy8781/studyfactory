import 'package:flutter/material.dart';

import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';

/// A consistent card container for StudyVerse UI.
/// Supports gradients, custom shadows, and tap interactions.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.color,
    this.border,
    this.shadows,
    this.onTap,
    this.onLongPress,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final LinearGradient? gradient;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Clip clipBehavior;

  /// Convenience factory for a gradient hero card.
  const AppCard.gradient({
    super.key,
    required this.child,
    required LinearGradient gradient,
    this.padding = const EdgeInsets.all(AppSizes.paddingCard),
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.clipBehavior = Clip.antiAlias,
  })  : gradient = gradient,
        color = null,
        border = null,
        shadows = null;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = widget.borderRadius ?? AppSizes.radiusLg;

    final card = Container(
      margin: widget.margin,
      padding: widget.padding ??
          const EdgeInsets.all(AppSizes.paddingCard),
      decoration: BoxDecoration(
        color: widget.gradient != null
            ? null
            : (widget.color ??
                (isDark ? AppColors.surfaceDark : AppColors.surface)),
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(radius),
        border: widget.border ??
            Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
        boxShadow:
            widget.shadows ?? AppColors.cardShadow,
      ),
      clipBehavior: widget.clipBehavior,
      child: widget.child,
    );

    if (widget.onTap == null && widget.onLongPress == null) {
      return card;
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: card,
      ),
    );
  }
}

/// Stat card used on the home / statistics screens.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.unit,
    this.gradient,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? unit;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: gradient,
      padding: const EdgeInsets.all(AppSizes.paddingCardLg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.icon3xl,
            height: AppSizes.icon3xl,
            decoration: BoxDecoration(
              color: gradient != null
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.primaryContainer,
              borderRadius:
                  BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconLg,
              color: gradient != null
                  ? Colors.white
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: gradient != null
                      ? Colors.white
                      : AppColors.primary,
                  height: 1,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: AppSizes.spaceXs),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: gradient != null
                          ? Colors.white.withOpacity(0.85)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.spaceXxs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: gradient != null
                  ? Colors.white.withOpacity(0.85)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
