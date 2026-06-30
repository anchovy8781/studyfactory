import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
final _top3 = [
  _RankUser(rank: 1, nickname: '공부맨', points: 2300, avatar: '👑', change: 0),
  _RankUser(rank: 2, nickname: '김스터디', points: 2450, avatar: '🥈', change: 1),
  _RankUser(rank: 3, nickname: '얼공이', points: 2150, avatar: '🥉', change: -1),
];

final _rankList = [
  _RankUser(rank: 4, nickname: '노력탄', points: 2000, avatar: '🔥', change: 2),
  _RankUser(rank: 5, nickname: '포기란없다', points: 1950, avatar: '💪', change: -1),
  _RankUser(rank: 6, nickname: '성실이', points: 1800, avatar: '📚', change: 0),
  _RankUser(rank: 7, nickname: '집중탄갑', points: 1750, avatar: '⚡', change: 3),
  _RankUser(rank: 8, nickname: '합격기원', points: 1700, avatar: '🌟', change: -2),
  _RankUser(rank: 9, nickname: '독서왕', points: 1650, avatar: '📖', change: 1),
  _RankUser(rank: 10, nickname: '공부벌레', points: 1580, avatar: '🐛', change: 0),
];

const _myRank = _RankUser(rank: 12, nickname: '김스터디(나)', points: 1350, avatar: '🐶', change: -1);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['크루 랭킹', '개인 랭킹'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
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
          labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelLarge,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildRankingContent(),
              _buildRankingContent(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMyRankBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildPodium()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('4위 ~ 10위',
                style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _buildRankRow(_rankList[i], i),
            childCount: _rankList.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  // ── Podium ───────────────────────────────────────────────────────────────
  Widget _buildPodium() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Text('이번 주 TOP 3',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place - left
              _buildPodiumItem(_top3[1], height: 100, isCenter: false),
              const SizedBox(width: 8),
              // 1st place - center
              _buildPodiumItem(_top3[0], height: 130, isCenter: true),
              const SizedBox(width: 8),
              // 3rd place - right
              _buildPodiumItem(_top3[2], height: 80, isCenter: false),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildPodiumItem(_RankUser user, {required double height, required bool isCenter}) {
    final bgColor = isCenter
        ? AppColors.primary
        : (user.rank == 2 ? AppColors.surfaceVariant : AppColors.surfaceVariant);
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
          Text('${user.points}P',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                '${user.rank}위',
                style: TextStyle(
                  fontSize: isCenter ? 22 : 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ).animate().slideY(begin: 0.3, duration: 500.ms, delay: (user.rank * 80).ms, curve: Curves.easeOut),
    );
  }

  // ── Rank list row ────────────────────────────────────────────────────────
  Widget _buildRankRow(_RankUser user, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${user.rank}',
              style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(user.avatar, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(user.nickname,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
          // Rank change indicator
          _buildChangeIndicator(user.change),
          const SizedBox(width: 10),
          Text('${user.points}P',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.05);
  }

  Widget _buildChangeIndicator(int change) {
    if (change == 0) {
      return const Icon(Icons.remove_rounded, color: AppColors.textSecondary, size: 16);
    } else if (change > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_upward_rounded, color: AppColors.success, size: 14),
          Text('$change',
              style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success, fontWeight: FontWeight.w700)),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_downward_rounded, color: AppColors.error, size: 14),
          Text('${change.abs()}',
              style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.error, fontWeight: FontWeight.w700)),
        ],
      );
    }
  }

  // ── My rank bar ──────────────────────────────────────────────────────────
  Widget _buildMyRankBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: AppColors.primaryShadow,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🐶', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('내 순위: ${_myRank.rank}위',
                      style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  Text('${_myRank.nickname}',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Text('${_myRank.points}P',
                style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 400.ms, delay: 300.ms);
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class _RankUser {
  final int rank;
  final String nickname;
  final int points;
  final String avatar;
  final int change;

  const _RankUser({
    required this.rank,
    required this.nickname,
    required this.points,
    required this.avatar,
    required this.change,
  });
}
