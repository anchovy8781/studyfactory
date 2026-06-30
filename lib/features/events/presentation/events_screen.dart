import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// 이벤트 안내. Firestore `events` 컬렉션(관리자 등록)을 읽고,
/// 비어있으면 기본 안내 이벤트를 보여줍니다.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        title: Text('이벤트', style: AppTextStyles.titleLarge),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final events = docs.isNotEmpty
              ? docs.map((d) {
                  final m = d.data();
                  return _Event(
                    (m['emoji'] as String?) ?? '🎉',
                    (m['title'] as String?) ?? '',
                    (m['body'] as String?) ?? '',
                    (m['period'] as String?) ?? '',
                  );
                }).toList()
              : _defaultEvents;
          return ListView(
            padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
            children: events.map(_card).toList(),
          );
        },
      ),
    );
  }

  Widget _card(_Event e) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.spaceXl),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
            ),
            child: Column(
              children: [
                Text(e.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 8),
                Text(e.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.body,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
                if (e.period.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('기간: ${e.period}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Event {
  const _Event(this.emoji, this.title, this.body, this.period);
  final String emoji;
  final String title;
  final String body;
  final String period;
}

const _defaultEvents = [
  _Event('🎉', '신규 가입 환영 이벤트',
      '가입 후 학습 활동으로 포인트를 모아보세요! 공부 10분당 5P, 연속 학습 매일 15P가 지급됩니다.', '상시'),
  _Event('🍱', '푸드카드 출시 기념',
      '포인트로 77종 푸드카드를 뽑아 도감을 완성해보세요. 전설 카드를 모아보세요!', '상시'),
  _Event('📺', '광고 보고 포인트 받기',
      '광고 센터에서 광고를 시청하면 포인트가 적립됩니다. 모은 포인트로 카드를 뽑아보세요!', '상시'),
];
