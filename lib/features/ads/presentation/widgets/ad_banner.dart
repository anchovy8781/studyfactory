import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Reusable banner-ad placeholder.
///
/// Drop this anywhere a banner ad should appear. When a real ad SDK
/// (e.g. google_mobile_ads) is added later, replace the inner content with the
/// actual `AdWidget` — the layout/size stays the same.
class AdBanner extends StatelessWidget {
  const AdBanner({super.key, this.height = 60});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingPageHorizontal,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined,
              size: AppSizes.iconMd, color: AppColors.textHint),
          const SizedBox(width: AppSizes.spaceSm),
          Text(
            '광고 영역',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
