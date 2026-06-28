import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outlined, ghost, danger }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = AppSizes.buttonHeightLg,
    this.borderRadius = AppSizes.radiusLg,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = !widget.isDisabled && !widget.isLoading;

    return GestureDetector(
      onTapDown: isActive ? (_) => setState(() => _pressed = true) : null,
      onTapUp: isActive
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isActive ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    final isActive = !widget.isDisabled && !widget.isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: widget.isDisabled ? AppSizes.opacityDisabled : 1.0,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: _buildDecoration(),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _loaderColor(),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.leadingIcon != null) ...[
                      widget.leadingIcon!,
                      const SizedBox(width: AppSizes.spaceSm),
                    ],
                    Text(widget.label, style: _labelStyle()),
                    if (widget.trailingIcon != null) ...[
                      const SizedBox(width: AppSizes.spaceSm),
                      widget.trailingIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.isDisabled ? null : AppColors.primaryShadow,
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      case AppButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.primary, width: AppSizes.borderWidthMd),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      case AppButtonVariant.danger:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFC62828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }

  TextStyle _labelStyle() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return AppTextStyles.button;
      case AppButtonVariant.secondary:
        return AppTextStyles.button.copyWith(color: AppColors.primary);
      case AppButtonVariant.outlined:
        return AppTextStyles.button.copyWith(color: AppColors.primary);
      case AppButtonVariant.ghost:
        return AppTextStyles.button.copyWith(color: AppColors.primary);
    }
  }

  Color _loaderColor() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      default:
        return AppColors.primary;
    }
  }
}
