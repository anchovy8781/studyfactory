import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/services/notification_service.dart';
import 'package:studyverse/features/ads/presentation/widgets/ad_banner.dart';

/// 광고 센터 — reward-ad hub.
///
/// Ads are not wired to a real SDK yet. The structure (rewarded-ad card +
/// banner placeholders) is ready, so adding google_mobile_ads later only
/// requires filling in [_watchRewardedAd] and replacing [AdBanner] internals.
class AdCenterScreen extends StatefulWidget {
  const AdCenterScreen({super.key});

  @override
  State<AdCenterScreen> createState() => _AdCenterScreenState();
}

class _AdCenterScreenState extends State<AdCenterScreen> {
  static const _rewardPoints = 50;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('광고 센터', style: AppTextStyles.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
        children: [
          _buildRewardCard(),
          const SizedBox(height: AppSizes.spaceXl),
          Text('제휴 광고', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSizes.spaceSm),
          const AdBanner(height: 100),
          const AdBanner(height: 100),
          const SizedBox(height: AppSizes.spaceXl),
          _buildInfo(),
        ],
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Column(
        children: [
          const Icon(Icons.play_circle_fill_rounded,
              color: Colors.white, size: 48),
          const SizedBox(height: AppSizes.spaceMd),
          Text(
            '광고 보고 포인트 받기',
            style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          Text(
            '짧은 광고를 시청하면 $_rewardPoints포인트를 드려요',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _watchRewardedAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('광고 보기',
                      style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.textSecondary, size: AppSizes.iconMd),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: Text(
              '실제 광고는 추후 연동 예정입니다. 광고 시청 시 포인트가 지급되며, '
              '적립한 포인트는 포인트 상점에서 사용할 수 있어요.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// Integration point for a real rewarded ad. For now it simulates a reward
  /// grant via Firestore. Replace the body with the AdMob rewarded-ad flow:
  /// load → show → on userEarnedReward → grant points.
  Future<void> _watchRewardedAd() async {
    final messenger = ScaffoldMessenger.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('광고 준비 중'),
        content: const Text(
            '실제 광고는 곧 연동됩니다.\n지금은 체험용으로 포인트를 지급할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('포인트 받기')),
        ],
      ),
    );
    if (proceed != true) return;

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'points': FieldValue.increment(_rewardPoints)});
      await NotificationService.instance
          .notify('포인트 적립 🎉', '광고 시청으로 $_rewardPoints포인트가 적립되었습니다!');
      messenger.showSnackBar(
        SnackBar(
          content: Text('$_rewardPoints포인트가 적립되었습니다!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('적립 실패: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
