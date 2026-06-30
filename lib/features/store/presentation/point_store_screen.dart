import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// A purchasable store item.
class _StoreItem {
  const _StoreItem(this.id, this.emoji, this.title, this.desc, this.cost);
  final String id;
  final String emoji;
  final String title;
  final String desc;
  final int cost;
}

const _items = <_StoreItem>[
  _StoreItem('remove_ads', '🚫', '광고 제거 (7일)', '7일간 광고 없이 집중', 1500),
  _StoreItem('theme_dark', '🌙', '다크 테마', '눈이 편한 어두운 테마', 800),
  _StoreItem('music_pack', '🎵', '집중 음악 팩', '무저작권 집중 음악 모음', 2000),
  _StoreItem('stats_pro', '📊', '통계 PRO', '상세 학습 분석 잠금 해제', 3000),
  _StoreItem('badge_gold', '🏅', '골드 뱃지', '프로필에 표시되는 골드 뱃지', 5000),
  _StoreItem('streak_freeze', '❄️', '연속 보호권', '하루 빠져도 연속 유지', 1200),
];

/// Point store — spend Firestore-backed points on items. No local/mock data.
class PointStoreScreen extends StatelessWidget {
  const PointStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = uid == null
        ? null
        : FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('포인트 상점', style: AppTextStyles.titleLarge),
      ),
      body: userDoc == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: userDoc.snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final points = (data?['points'] as num?)?.toInt() ?? 0;
                final owned = ((data?['ownedItems'] as List?) ?? const [])
                    .map((e) => e.toString())
                    .toSet();

                return Column(
                  children: [
                    _buildBalance(points),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.spaceMd),
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          final ownedAlready = owned.contains(item.id);
                          return _buildItemCard(
                            context,
                            userDoc,
                            item,
                            points,
                            ownedAlready,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildBalance(int points) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Column(
        children: [
          Text('보유 포인트',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text('$points P',
              style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> userDoc,
    _StoreItem item,
    int points,
    bool owned,
  ) {
    final canBuy = !owned && points >= item.cost;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppSizes.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.desc,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          owned
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text('보유중',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.success)),
                )
              : ElevatedButton(
                  onPressed: canBuy
                      ? () => _purchase(context, userDoc, item, points)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),
                  child: Text('${item.cost}P',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
        ],
      ),
    );
  }

  Future<void> _purchase(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> userDoc,
    _StoreItem item,
    int points,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('구매 확인'),
        content: Text('${item.title}을(를) ${item.cost}P에 구매하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('구매')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(userDoc);
        final current = (snap.data()?['points'] as num?)?.toInt() ?? 0;
        if (current < item.cost) {
          throw '포인트가 부족합니다.';
        }
        tx.update(userDoc, {
          'points': current - item.cost,
          'ownedItems': FieldValue.arrayUnion([item.id]),
        });
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('${item.title} 구매 완료!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
