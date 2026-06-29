import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';

class ForgettingCurveScreen extends StatefulWidget {
  const ForgettingCurveScreen({super.key});
  @override
  State<ForgettingCurveScreen> createState() => _ForgettingCurveScreenState();
}

class _ForgettingCurveScreenState extends State<ForgettingCurveScreen> {
  final List<_ReviewItem> _items = [
    _ReviewItem(topic: '전기자기학 기초', learnedAt: DateTime.now().subtract(const Duration(hours: 23)), retentionRate: 0.72),
    _ReviewItem(topic: '회로이론 RC회로', learnedAt: DateTime.now().subtract(const Duration(days: 2)), retentionRate: 0.45),
    _ReviewItem(topic: '전력공학 송배전', learnedAt: DateTime.now().subtract(const Duration(days: 6)), retentionRate: 0.28),
    _ReviewItem(topic: '제어공학 전달함수', learnedAt: DateTime.now().subtract(const Duration(days: 13)), retentionRate: 0.18),
  ];

  Color _retentionColor(double r) {
    if (r >= 0.7) return AppColors.success;
    if (r >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  String _nextReview(double r) {
    if (r >= 0.7) return '3일 후';
    if (r >= 0.4) return '오늘';
    return '지금 당장!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('망각곡선 복습 알림'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('에빙하우스 망각곡선', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('최적 복습 시점을 놓치지 마세요', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              const SizedBox(height: AppSizes.spaceMd),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _CurvePoint(time: '1일 후', retention: '56%'),
                _CurvePoint(time: '7일 후', retention: '33%'),
                _CurvePoint(time: '30일 후', retention: '20%'),
              ]),
            ]),
          ),
          const SizedBox(height: AppSizes.spaceLg),
          Text('복습 필요 단원', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSizes.spaceMd),
          ..._items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: AppSizes.spaceMd),
            padding: const EdgeInsets.all(AppSizes.spaceMd),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.topic, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Text('학습: ${_timeAgo(item.learnedAt)} · 다음 복습: ${_nextReview(item.retentionRate)}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: item.retentionRate, backgroundColor: AppColors.border, color: _retentionColor(item.retentionRate), minHeight: 6, borderRadius: BorderRadius.circular(3)),
              ])),
              const SizedBox(width: AppSizes.spaceMd),
              Column(children: [
                Text('${(item.retentionRate * 100).toInt()}%', style: AppTextStyles.titleMedium.copyWith(color: _retentionColor(item.retentionRate), fontWeight: FontWeight.w800)),
                Text('기억률', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ]),
            ]),
          )),
          const SizedBox(height: AppSizes.spaceMd),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text('단원 추가'),
                content: const TextField(decoration: InputDecoration(labelText: '단원명', border: OutlineInputBorder())),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('추가'))],
              ));
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('복습할 단원 추가'),
          ),
        ]),
      ),
    );
  }
}

class _ReviewItem {
  const _ReviewItem({required this.topic, required this.learnedAt, required this.retentionRate});
  final String topic;
  final DateTime learnedAt;
  final double retentionRate;
}

class _CurvePoint extends StatelessWidget {
  const _CurvePoint({required this.time, required this.retention});
  final String time;
  final String retention;
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(retention, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
    Text(time, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
  ]);
}
