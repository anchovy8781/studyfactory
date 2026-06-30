import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/community/presentation/community_screen.dart'
    show createPost;

/// Continuous-study (연속 학습) record screen.
///
/// Shows the current streak, the all-time best streak and a log of past study
/// sessions. Lets the user brag about their streak to the community and share
/// it to other apps.
class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  DocumentReference<Map<String, dynamic>>? get _me {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text('연속 학습 기록', style: AppTextStyles.titleLarge),
      ),
      body: me == null
          ? _empty('로그인이 필요합니다.')
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: me.snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() ?? {};
                final streak = (data['streakDays'] as num?)?.toInt() ?? 0;
                final best = (data['bestStreak'] as num?)?.toInt() ?? 0;
                final totalHours =
                    (data['totalStudyHours'] as num?)?.toDouble() ?? 0;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _buildHeroCard(streak, best, totalHours),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard('🏆 최고 기록', '$best일',
                              const Color(0xFFEF6C00)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard('⏱ 누적 학습',
                              '${totalHours.toStringAsFixed(1)}h', AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _bragToCommunity(context, streak, best),
                            icon: const Icon(Icons.campaign_rounded),
                            label: const Text('커뮤니티에 자랑'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _share(streak, best, totalHours),
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('공유하기'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('학습 기록', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 8),
                    _buildSessionList(me),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildHeroCard(int streak, int best, double totalHours) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A00), Color(0xFFFF5252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text('$streak일 연속 학습 중',
              style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('내일도 이어가면 ${streak + 1}일! 화이팅 💪',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.titleLarge
                  .copyWith(color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSessionList(DocumentReference<Map<String, dynamic>> me) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: me
          .collection('studySessions')
          .orderBy('createdAt', descending: true)
          .limit(60)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _empty('기록을 불러올 수 없습니다.');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _empty('아직 학습 기록이 없어요.\n공부를 완료하면 여기에 기록됩니다!');
        }
        return Column(
          children: docs.map((d) {
            final m = d.data();
            final minutes = (m['minutes'] as num?)?.toInt() ?? 0;
            final subject = (m['subject'] as String?)?.trim() ?? '';
            final date = (m['date'] as String?) ?? '';
            final focus = (m['focusScore'] as num?)?.toDouble() ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subject.isEmpty ? '공부 세션' : subject,
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700)),
                        Text(date,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$minutes분',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text('집중 ${focus.toStringAsFixed(0)}%',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _streakMessage(int streak, int best) =>
      '🔥 $streak일 연속 공부 중! (최고 기록 $best일)\n오늘도 StudyVerse와 함께 공부 인증 완료 💪 #StudyVerse #공부인증';

  Future<void> _bragToCommunity(
      BuildContext context, int streak, int best) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('커뮤니티에 자랑하기'),
        content: Text('"$streak일 연속 학습" 기록을 커뮤니티에 게시할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('게시')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await createPost(_streakMessage(streak, best), '연속학습');
      messenger.showSnackBar(const SnackBar(
        content: Text('커뮤니티에 자랑글이 게시되었습니다! 🎉'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('게시 실패: $e'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _share(int streak, int best, double totalHours) {
    Share.share(
      '${_streakMessage(streak, best)}\n누적 학습 시간 ${totalHours.toStringAsFixed(1)}시간',
      subject: 'StudyVerse 연속 학습 기록',
    );
  }

  Widget _empty(String text) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ),
      );
}
