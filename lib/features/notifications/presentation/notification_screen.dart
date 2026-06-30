import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await NotificationService.instance.getInbox();
    await NotificationService.instance.markAllRead();
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  Future<void> _clear() async {
    await NotificationService.instance.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('알림', style: AppTextStyles.titleLarge),
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _clear,
              child: Text('전체 삭제',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _empty()
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.spaceMd),
                  itemBuilder: (context, i) => _tile(_items[i]),
                ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none_rounded,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text('새로운 알림이 없습니다.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _tile(AppNotification n) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(n.body,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(_timeAgo(n.date),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return '방금 전';
    if (d.inMinutes < 60) return '${d.inMinutes}분 전';
    if (d.inHours < 24) return '${d.inHours}시간 전';
    return '${d.inDays}일 전';
  }
}
