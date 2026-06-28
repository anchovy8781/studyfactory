import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
final _rankingMembers = [
  _MemberRank(rank: 1, nickname: '김스터디', hours: 45, avatar: '👑'),
  _MemberRank(rank: 2, nickname: '공부하는강아지', hours: 38, avatar: '🐶'),
  _MemberRank(rank: 3, nickname: '합격기원', hours: 32, avatar: '🔥'),
  _MemberRank(rank: 4, nickname: '노력탄', hours: 28, avatar: '⚡'),
  _MemberRank(rank: 5, nickname: '포기란없다', hours: 24, avatar: '💪'),
];

final _crewList = [
  _CrewData(
    name: '전기기사 합격 크루',
    description: '함께 공부하고 함께 합격해요!',
    members: 128,
    icon: '⚡',
    isJoined: true,
    weeklyHours: 180,
    tag: '전기기사',
  ),
  _CrewData(
    name: '정보처리기사 스터디',
    description: '합격할 때까지 같이 달려요!',
    members: 94,
    icon: '💻',
    isJoined: false,
    weeklyHours: 120,
    tag: '정보처리기사',
  ),
  _CrewData(
    name: '공무원 준비생 모임',
    description: '9급 공무원 함께 준비해요',
    members: 256,
    icon: '📋',
    isJoined: false,
    weeklyHours: 340,
    tag: '공무원',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class CrewScreen extends ConsumerStatefulWidget {
  const CrewScreen({super.key});

  @override
  ConsumerState<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends ConsumerState<CrewScreen> {
  bool _joinedFeatured = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('크루', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedCrewCard(),
            const SizedBox(height: 20),
            _buildRankingSection(),
            const SizedBox(height: 20),
            _buildCrewListSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: Text('크루 만들기', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ).animate().scale(delay: 300.ms),
    );
  }

  // ── Featured crew card ───────────────────────────────────────────────────
  Widget _buildFeaturedCrewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('추천 크루',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('전기기사 합격 크루',
                        style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('함께 공부하고 함께 합격해요!',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCrewStat(Icons.people_rounded, '128명'),
              const SizedBox(width: 20),
              _buildCrewStat(Icons.timer_rounded, '주간 180시간'),
              const SizedBox(width: 20),
              _buildCrewStat(Icons.emoji_events_rounded, '활성 크루'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _joinedFeatured = !_joinedFeatured),
              style: ElevatedButton.styleFrom(
                backgroundColor: _joinedFeatured ? Colors.white24 : Colors.white,
                foregroundColor: _joinedFeatured ? Colors.white : AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                _joinedFeatured ? '크루 탈퇴하기' : '크루 참여하기',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildCrewStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
      ],
    );
  }

  // ── Ranking section ──────────────────────────────────────────────────────
  Widget _buildRankingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('크루 랭킹',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
              Text('이번 주',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_rankingMembers.length, (i) {
            final m = _rankingMembers[i];
            return _buildRankRow(m, i).animate()
              .fadeIn(duration: 300.ms, delay: (i * 60).ms)
              .slideX(begin: 0.05);
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildRankRow(_MemberRank member, int index) {
    final rankColors = [AppColors.warning, AppColors.textSecondary, const Color(0xFFCD7F32)];
    final rankColor = member.rank <= 3 ? rankColors[member.rank - 1] : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${member.rank}',
              style: AppTextStyles.titleSmall.copyWith(
                  color: rankColor, fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(member.avatar, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(member.nickname,
                style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
          Text('${member.hours}시간',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── Crew list ────────────────────────────────────────────────────────────
  Widget _buildCrewListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('다른 크루 둘러보기',
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ..._crewList.map((crew) => _buildCrewCard(crew)),
      ],
    );
  }

  Widget _buildCrewCard(_CrewData crew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(crew.icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crew.name,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(crew.description,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text('${crew.members}명',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('#${crew.tag}',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text('참여',
                style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
class _MemberRank {
  final int rank;
  final String nickname;
  final int hours;
  final String avatar;

  const _MemberRank({
    required this.rank,
    required this.nickname,
    required this.hours,
    required this.avatar,
  });
}

class _CrewData {
  final String name;
  final String description;
  final int members;
  final String icon;
  final bool isJoined;
  final int weeklyHours;
  final String tag;

  const _CrewData({
    required this.name,
    required this.description,
    required this.members,
    required this.icon,
    required this.isJoined,
    required this.weeklyHours,
    required this.tag,
  });
}
