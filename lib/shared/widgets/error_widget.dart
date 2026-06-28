import 'package:flutter/material.dart';

import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_strings.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/errors/failure.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

/// Full-screen error state widget.
/// Displays an icon, message, and optional retry button.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.failure,
    this.message,
    this.onRetry,
    this.icon,
    this.title,
  });

  final Failure? failure;
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? title;

  String get _resolvedMessage {
    if (message != null) return message!;
    if (failure == null) return AppStrings.unknownError;
    return switch (failure!) {
      NetworkFailure() => AppStrings.noInternet,
      AuthFailure() => AppStrings.sessionExpired,
      NotFoundFailure() => AppStrings.noData,
      ServerFailure() => AppStrings.serverError,
      _ => failure!.message,
    };
  }

  IconData get _resolvedIcon {
    if (icon != null) return icon!;
    if (failure == null) return Icons.error_outline_rounded;
    return switch (failure!) {
      NetworkFailure() => Icons.wifi_off_rounded,
      AuthFailure() => Icons.lock_outline_rounded,
      NotFoundFailure() => Icons.search_off_rounded,
      ServerFailure() => Icons.cloud_off_rounded,
      _ => Icons.error_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingSection),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizes.icon4xl + AppSizes.spaceLg,
              height: AppSizes.icon4xl + AppSizes.spaceLg,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _resolvedIcon,
                size: AppSizes.icon4xl,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceXs),
            ],
            Text(
              _resolvedMessage,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.spaceXxl),
              AppButton(
                label: AppStrings.retry,
                onPressed: onRetry,
                variant: AppButtonVariant.outline,
                icon: Icons.refresh_rounded,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error message (for forms, etc.)
class InlineErrorMessage extends StatelessWidget {
  const InlineErrorMessage({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: AppSizes.iconSm,
          color: AppColors.error,
        ),
        const SizedBox(width: AppSizes.spaceXs),
        Expanded(
          child: Text(
            message,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

/// Empty state widget (no data to show).
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.action,
    this.actionLabel,
  });

  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingSection),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: AppSizes.icon5xl,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.spaceLg),
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceXs),
            ],
            Text(
              message ?? AppStrings.noData,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: AppSizes.spaceXxl),
              AppButton(
                label: actionLabel!,
                onPressed: action,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
