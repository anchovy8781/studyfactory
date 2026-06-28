import 'package:flutter/material.dart';

import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Visual style variant for [AppButton].
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  success,
}

/// Size presets for [AppButton].
enum AppButtonSize { small, medium, large }

/// Fully animated, gradient-capable button for StudyVerse.
///
/// Usage:
/// ```dart
/// AppButton(
///   label: '공부 시작',
///   onPressed: () => ...,
///   icon: Icons.play_arrow,
/// )
/// ```
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.medium,
    this.gradient,
    this.borderRadius,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonSize size;
  final LinearGradient? gradient;
  final double? borderRadius;
  final EdgeInsets? padding;

  /// Convenience constructor for a danger/destructive action.
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.medium,
  })  : variant = AppButtonVariant.danger,
        trailingIcon = null,
        gradient = null,
        borderRadius = null,
        padding = null;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!_isDisabled) _scaleController.forward();
  }

  void _onTapUp(TapUpDetails _) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  double get _height => switch (widget.size) {
        AppButtonSize.small => AppSizes.buttonHeightSm,
        AppButtonSize.medium => AppSizes.buttonHeightMd,
        AppButtonSize.large => AppSizes.buttonHeightLg,
      };

  TextStyle get _textStyle => switch (widget.size) {
        AppButtonSize.small => AppTextStyles.buttonSmall,
        AppButtonSize.medium => AppTextStyles.button,
        AppButtonSize.large => AppTextStyles.button.copyWith(fontSize: 18),
      };

  double get _iconSize => switch (widget.size) {
        AppButtonSize.small => AppSizes.iconSm,
        AppButtonSize.medium => AppSizes.iconMd,
        AppButtonSize.large => AppSizes.iconLg,
      };

  EdgeInsets get _resolvedPadding =>
      widget.padding ??
      switch (widget.size) {
        AppButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        AppButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        AppButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      };

  double get _radius => widget.borderRadius ?? AppSizes.radiusLg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isDisabled ? AppSizes.opacityDisabled : 1.0,
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final radius = BorderRadius.circular(_radius);
    return switch (widget.variant) {
      AppButtonVariant.primary => _GradientButton(
          gradient: widget.gradient ?? AppColors.primaryGradient,
          borderRadius: radius,
          height: _height,
          isFullWidth: widget.isFullWidth,
          padding: _resolvedPadding,
          shadow: AppColors.primaryShadow,
          child: _buildInner(color: AppColors.textOnPrimary),
        ),
      AppButtonVariant.secondary => _GradientButton(
          gradient: AppColors.accentGradient,
          borderRadius: radius,
          height: _height,
          isFullWidth: widget.isFullWidth,
          padding: _resolvedPadding,
          shadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
          child: _buildInner(color: AppColors.textOnAccent),
        ),
      AppButtonVariant.success => _GradientButton(
          gradient: AppColors.successGradient,
          borderRadius: radius,
          height: _height,
          isFullWidth: widget.isFullWidth,
          padding: _resolvedPadding,
          shadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
          child: _buildInner(color: AppColors.textOnPrimary),
        ),
      AppButtonVariant.danger => _GradientButton(
          gradient: const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFC62828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          height: _height,
          isFullWidth: widget.isFullWidth,
          padding: _resolvedPadding,
          shadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
          child: _buildInner(color: AppColors.textOnPrimary),
        ),
      AppButtonVariant.outline => _OutlineButton(
          color: AppColors.primary,
          borderRadius: radius,
          height: _height,
          isFullWidth: widget.isFullWidth,
          padding: _resolvedPadding,
          child: _buildInner(color: AppColors.primary),
        ),
      AppButtonVariant.ghost => _GhostButton(
          borderRadius: radius,
          height: _height,
          isFullWidth: widget.isFullWidth,
          padding: _resolvedPadding,
          child: _buildInner(color: AppColors.primary),
        ),
    };
  }

  Widget _buildInner({required Color color}) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisSize:
          widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: _iconSize, color: color),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: _textStyle.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.trailingIcon, size: _iconSize, color: color),
        ],
      ],
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.gradient,
    required this.borderRadius,
    required this.height,
    required this.isFullWidth,
    required this.padding,
    required this.child,
    this.shadow,
  });

  final LinearGradient gradient;
  final BorderRadius borderRadius;
  final double height;
  final bool isFullWidth;
  final EdgeInsets padding;
  final Widget child;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
          boxShadow: shadow,
        ),
        padding: padding,
        child: Center(child: child),
      );
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.color,
    required this.borderRadius,
    required this.height,
    required this.isFullWidth,
    required this.padding,
    required this.child,
  });

  final Color color;
  final BorderRadius borderRadius;
  final double height;
  final bool isFullWidth;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: borderRadius,
          border:
              Border.all(color: color, width: AppSizes.borderWidthLg),
        ),
        padding: padding,
        child: Center(child: child),
      );
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.borderRadius,
    required this.height,
    required this.isFullWidth,
    required this.padding,
    required this.child,
  });

  final BorderRadius borderRadius;
  final double height;
  final bool isFullWidth;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: borderRadius,
        ),
        padding: padding,
        child: Center(child: child),
      );
}
