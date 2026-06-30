import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Full point ledger — earnings (수령내역) and spending (교환내역).
class PointHistoryScreen extends StatefulWidget {
  const PointHistoryScreen({super.key});

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  int _tab = 0; // 0 전체, 1 수령, 2 교환

  Query<Map<String, dynamic>>? get _query {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pointHistory')
        .orderBy('createdAt', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        title: Text('포인트 내역', style: AppTextStyles.titleLarge),
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['전체보기', '수령내역', '교환내역'];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final sel = i == _tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(labels[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: sel ? Colors.white : AppColors.textSecondary,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    )),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildList() {
    final q = _query;
    if (q == null) {
      return const Center(child: Text('로그인이 필요합니다.'));
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snapshot.data!.docs;
        if (_tab == 1) {
          docs = docs.where((d) => d.data()['type'] == 'earn').toList();
        } else if (_tab == 2) {
          docs = docs.where((d) => d.data()['type'] == 'spend').toList();
        }
        if (docs.isEmpty) {
          return Center(
            child: Text('내역이 없습니다.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _row(docs[i].data()),
        );
      },
    );
  }

  Widget _row(Map<String, dynamic> m) {
    final amount = (m['amount'] as num?)?.toInt() ?? 0;
    final reason = (m['reason'] as String?) ?? '';
    final earn = amount >= 0;
    final ts = (m['createdAt'] as Timestamp?)?.toDate();
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (earn ? AppColors.success : AppColors.error)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(earn ? Icons.add_rounded : Icons.remove_rounded,
                color: earn ? AppColors.success : AppColors.error),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reason,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                if (ts != null)
                  Text(_fmt(ts),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          Text('${earn ? '+' : ''}$amount P',
              style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: earn ? AppColors.success : AppColors.error)),
        ],
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
