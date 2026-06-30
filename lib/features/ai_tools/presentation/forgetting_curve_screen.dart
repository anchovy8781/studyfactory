import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';

class ForgettingCurveScreen extends StatefulWidget {
  const ForgettingCurveScreen({super.key});
  @override
  State<ForgettingCurveScreen> createState() => _ForgettingCurveScreenState();
}

class _ForgettingCurveScreenState extends State<ForgettingCurveScreen> {
  static const _storeKey = 'forgetting_curve_items';
  // Starts empty for every new user — topics are added as you study.
  List<_ReviewItem> _items = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    final list = <_ReviewItem>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        for (final e in jsonDecode(raw) as List) {
          list.add(_ReviewItem.fromJson(Map<String, dynamic>.from(e as Map)));
        }
      } catch (_) {/* ignore corrupt data */}
    }
    if (mounted) setState(() {
      _items = list;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storeKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  /// Ebbinghaus retention: R = e^(-elapsedDays / stability).
  double _retention(_ReviewItem item) {
    final days = DateTime.now().difference(item.learnedAt).inMinutes / 1440.0;
    final r = math.exp(-days / (1.8 + item.reviewCount * 1.6));
    return r.clamp(0.0, 1.0);
  }

  Color _retentionColor(double r) {
    if (r >= 0.7) return AppColors.success;
    if (r >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '방금';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  String _nextReview(double r) {
    if (r >= 0.7) return '3일 후';
    if (r >= 0.4) return '오늘';
    return '지금 당장!';
  }

  Future<void> _addTopic() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('복습할 단원 추가'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: '단원명', border: OutlineInputBorder()),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('추가')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    setState(() => _items.add(
        _ReviewItem(topic: name, learnedAt: DateTime.now(), reviewCount: 0)));
    await _save();
  }

  Future<void> _markReviewed(int index) async {
    setState(() {
      final it = _items[index];
      _items[index] = _ReviewItem(
          topic: it.topic,
          learnedAt: DateTime.now(),
          reviewCount: it.reviewCount + 1);
    });
    await _save();
  }

  Future<void> _remove(int index) async {
    setState(() => _items.removeAt(index));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('망각곡선 복습 알림'),
          backgroundColor: Colors.transparent,
          elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTopic,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('단원 추가', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceLg, AppSizes.spaceLg, AppSizes.spaceLg, 96),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('에빙하우스 망각곡선',
                  style:
                      AppTextStyles.titleLarge.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('최적 복습 시점을 놓치지 마세요',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white70)),
              const SizedBox(height: AppSizes.spaceMd),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _CurvePoint(time: '1일 후', retention: '56%'),
                    _CurvePoint(time: '7일 후', retention: '33%'),
                    _CurvePoint(time: '30일 후', retention: '20%'),
                  ]),
            ]),
          ),
          const SizedBox(height: AppSizes.spaceLg),
          Text('복습 필요 단원', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSizes.spaceMd),
          if (_loaded && _items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  '아직 등록된 단원이 없어요.\n복습할 단원을 추가하면 최적 복습 시점을 알려드려요!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          ..._items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final r = _retention(item);
            return Container(
              margin: const EdgeInsets.only(bottom: AppSizes.spaceMd),
              padding: const EdgeInsets.all(AppSizes.spaceMd),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(item.topic, style: AppTextStyles.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                          '학습: ${_timeAgo(item.learnedAt)} · 다음 복습: ${_nextReview(r)}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                          value: r,
                          backgroundColor: AppColors.border,
                          color: _retentionColor(r),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3)),
                      const SizedBox(height: 8),
                      Row(children: [
                        TextButton.icon(
                          onPressed: () => _markReviewed(i),
                          icon: const Icon(Icons.check_circle_outline,
                              size: 16),
                          label: const Text('복습 완료'),
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppColors.primary),
                        ),
                        TextButton.icon(
                          onPressed: () => _remove(i),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('삭제'),
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppColors.textSecondary),
                        ),
                      ]),
                    ])),
                const SizedBox(width: AppSizes.spaceMd),
                Column(children: [
                  Text('${(r * 100).toInt()}%',
                      style: AppTextStyles.titleMedium.copyWith(
                          color: _retentionColor(r),
                          fontWeight: FontWeight.w800)),
                  Text('기억률',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ]),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

class _ReviewItem {
  const _ReviewItem(
      {required this.topic,
      required this.learnedAt,
      required this.reviewCount});
  final String topic;
  final DateTime learnedAt;
  final int reviewCount;

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'learnedAt': learnedAt.millisecondsSinceEpoch,
        'reviewCount': reviewCount,
      };

  factory _ReviewItem.fromJson(Map<String, dynamic> j) => _ReviewItem(
        topic: j['topic'] as String? ?? '',
        learnedAt: DateTime.fromMillisecondsSinceEpoch(
            (j['learnedAt'] as num?)?.toInt() ?? 0),
        reviewCount: (j['reviewCount'] as num?)?.toInt() ?? 0,
      );
}

class _CurvePoint extends StatelessWidget {
  const _CurvePoint({required this.time, required this.retention});
  final String time;
  final String retention;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(retention,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        Text(time,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ]);
}
