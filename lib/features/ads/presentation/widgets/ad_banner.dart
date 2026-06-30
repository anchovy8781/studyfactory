import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/services/ad_service.dart';

/// Real Google AdMob banner ad. Falls back to a subtle placeholder while the
/// ad loads or if it fails (e.g. no fill / offline).
class AdBanner extends StatefulWidget {
  const AdBanner({super.key, this.height = 60});

  final double height;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: AdService.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded && _ad != null) {
      return Container(
        alignment: Alignment.center,
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingPageHorizontal,
          vertical: AppSizes.spaceSm,
        ),
        child: AdWidget(ad: _ad!),
      );
    }
    // Placeholder while loading / on failure.
    return Container(
      width: double.infinity,
      height: widget.height,
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
          Text('광고 로딩 중...',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}
