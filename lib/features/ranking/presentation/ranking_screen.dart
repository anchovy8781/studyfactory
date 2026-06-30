import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Monthly study ranking (개인 랭킹), ranked by this month's study minutes.
///
/// Resets on the 1st of each month and rewards are paid out automatically by a
/// scheduled Cloud Function: 1–10위 3000P, 11–50위 1000P.
class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['개인 랭킹', '크루 랭킹'];

  static const _avatars = ['🦊', '🐶', '🐱', '🐰', '🐻', '🐼', '🐯', '🦁', '🐸', '🐵'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('랭킹', style: AppTextStyles.titleLarge),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          labelStyle:
              AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelLarge,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalRanking(),
          _buildCrewPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildRewardBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이번 달 공부 시간 랭킹',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('매월 1일 자동 갱신 · 1~10위 3000P · 11~50위 1000P 지급',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalRanking() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // Reads a privacy-safe public collection (nickname + minutes only) instead
    // of the protected `users` collection.
    final query = FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy('monthlyStudyMinutes', descending: true)
        .limit(50);
    return Column(
      children: [
        _buildRewardBanner(),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _info(
                    '랭킹을 불러올 수 없습니다.\nmonthlyStudyMinutes 색인이 필요할 수 있어요.');
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs
                  .where((d) =>
                      ((d.data()['monthlyStudyMinutes'] as num?)?.toInt() ?? 0) >
                      0)
                  .toList();
              if (docs.isEmpty) {
                return _info('아직 이번 달 공부 기록이 없어요.\n공부를 시작하면 랭킹에 등록됩니다!');
              }
              final users = <_RankUser>[];
              for (var i = 0; i < docs.length; i++) {
                final m = docs[i].data();
                users.add(_RankUser(
                  rank: i + 1,
                  uid: docs[i].id,
                  nickname: (m['nickname'] as String?)?.trim().isNotEmpty == true
                      ? m['nickname'] as String
                      : '익명',
                  minutes: (m['monthlyStudyMinutes'] as num?)?.toInt() ?? 0,
                  avatar: _avatars[i % _avatars.length],
                ));
              }
              final top3 = users.take(3).toList();
              final rest = users.skip(3).toList();
              final myIndex = users.indexWhere((u) => u.uid == uid);

              return Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: 90),
                    children: [
                      _buildPodium(top3),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text('4위 ~',
                            style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                      ...rest.asMap().entries.map(
                          (e) => _buildRankRow(e.value, e.key, uid)),
                    ],
                  ),
                  if (myIndex >= 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildMyRankBar(users[myIndex]),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCrewPlaceholder() {
    return _info('크루 랭킹은 준비 중입니다.\n곧 친구들과 함께하는 랭킹이 열려요!');
  }

  Widget _buildPodium(List<_RankUser> top3) {
    if (top3.isEmpty) return const SizedBox.shrink();
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Text('이번 달 TOP 3',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (second != null)
                _buildPodiumItem(second, height: 100, isCenter: false)
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 8),
              _buildPodiumItem(first, height: 130, isCenter: true),
              const SizedBox(width: 8),
              if (third != null)
                _buildPodiumItem(third, height: 80, isCenter: false)
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildPodiumItem(_RankUser user,
      {required double height, required bool isCenter}) {
    final bgColor = isCenter ? AppColors.primary : AppColors.surfaceVariant;
    final textColor = isCenter ? Colors.white : AppColors.textPrimary;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(user.avatar, style: TextStyle(fontSize: isCenter ? 40 : 30)),
          const SizedBox(height: 6),
          Text(user.nickname,
              style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(user.timeLabel,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text('${user.rank}위',
                  style: TextStyle(
                      fontSize: isCenter ? 22 : 18,
                      fontWeight: FontWeight.w800,
                      color: textColor)),
            ),
          ),
        ],
      ).animate().slideY(
          begin: 0.3,
          duration: 500.ms,
          delay: (user.rank * 80).ms,
          curve: Curves.easeOut),
    );
  }

  Widget _buildRankRow(_RankUser user, int index, String? myUid) {
    final isMe = user.uid == myUid;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryContainer : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${user.rank}',
                style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: Center(
                child:
                    Text(user.avatar, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(user.nickname,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          Text(user.timeLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms).slideX(begin: 0.05);
  }

  Widget _buildMyRankBar(_RankUser me) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.primary, boxShadow: AppColors.primaryShadow),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
              child: Center(
                  child: Text(me.avatar, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('내 순위: ${me.rank}위',
                      style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  Text(me.nickname,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Text(me.timeLabel,
                style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 400.ms, delay: 300.ms);
  }

  Widget _info(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ),
      );
}

class _RankUser {
  const _RankUser({
    required this.rank,
    required this.uid,
    required this.nickname,
    required this.minutes,
    required this.avatar,
  });

  final int rank;
  final String uid;
  final String nickname;
  final int minutes;
  final String avatar;

  String get timeLabel {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '$h시간 $m분' : '$m분';
  }
}
