import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
final _badges = [
  _BadgeData(
    emoji: '⭐',
    name: '첫 시작',
    description: '처음 공부를 시작했어요!',
    isUnlocked: true,
    isCurrent: false,
    color: AppColors.warning,
  ),
  _BadgeData(
    emoji: '🏆',
    name: '7일 연속',
    description: '7일 연속 공부를 완료했어요!',
    isUnlocked: true,
    isCurrent: true,
    color: AppColors.warning,
  ),
  _BadgeData(
    emoji: '🔥',
    name: '30일 연속',
    description: '30일 연속 공부에 도전해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.accent,
  ),
  _BadgeData(
    emoji: '⏰',
    name: '100시간',
    description: '총 100시간을 공부해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.primary,
  ),
  _BadgeData(
    emoji: '🤖',
    name: 'AI 마스터',
    description: 'AI 코치를 100번 사용해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: const Color(0xFF9C27B0),
  ),
  _BadgeData(
    emoji: '🌙',
    name: '방성의 신',
    description: '밤 12시 이후 10회 공부해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: const Color(0xFF3F51B5),
  ),
  _BadgeData(
    emoji: '💡',
    name: '집중왕',
    description: '집중도 90% 이상을 5회 달성하세요',
    isUnlocked: true,
    isCurrent: false,
    color: AppColors.warning,
  ),
  _BadgeData(
    emoji: '👑',
    name: '랭킹 1위',
    description: '주간 랭킹 1위를 달성해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.warning,
  ),
  _BadgeData(
    emoji: '🎓',
    name: '합격 축하',
    description: '자격증 합격을 인증해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.success,
  ),
  _BadgeData(
    emoji: '🌅',
    name: '아침형 인간',
    description: '오전 6시 이전에 10회 공부해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.accent,
  ),
  _BadgeData(
    emoji: '💯',
    name: '완벽한 하루',
    description: '하루 목표를 100% 달성해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.success,
  ),
  _BadgeData(
    emoji: '🤝',
    name: '인싸',
    description: '추천인 5명을 초대해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: const Color(0xFF00B894),
  ),
  _BadgeData(
    emoji: '✍️',
    name: '첫 게시글',
    description: '커뮤니티에 첫 글을 작성해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.primary,
  ),
  _BadgeData(
    emoji: '❤️',
    name: '인기글',
    description: '게시글 좋아요 50개를 받아보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.error,
  ),
  _BadgeData(
    emoji: '🎯',
    name: '100일 연속',
    description: '100일 연속 공부에 도전해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.accent,
  ),
  _BadgeData(
    emoji: '🥇',
    name: '포인트 부자',
    description: '10,000 포인트를 모아보세요',
    isUnlocked: false,
    isCurrent: false,
    color: AppColors.warning,
  ),
  _BadgeData(
    emoji: '⚡',
    name: '스피드러너',
    description: '하루에 8시간을 공부해보세요',
    isUnlocked: false,
    isCurrent: false,
    color: const Color(0xFF3F51B5),
  ),
  _BadgeData(
    emoji: '🧠',
    name: '지식왕',
    description: 'AI 플래시카드를 100개 만들어보세요',
    isUnlocked: false,
    isCurrent: false,
    color: const Color(0xFF9C27B0),
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  _BadgeData? _selectedBadge;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_BadgeData> get _filteredBadges {
    switch (_selectedTab) {
      case 1:
        return _badges.where((b) => b.isUnlocked).toList();
      case 2:
        return _badges.where((b) => !b.isUnlocked).toList();
      default:
        return _badges;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('내 뱃지', style: AppTextStyles.titleLarge),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '전체'), Tab(text: '획득'), Tab(text: '미획득')],
          labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelLarge,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBadgeGrid(_badges),
                _buildBadgeGrid(_badges.where((b) => b.isUnlocked).toList()),
                _buildBadgeGrid(_badges.where((b) => !b.isUnlocked).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    final unlockedCount = _badges.where((b) => b.isUnlocked).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          Text('$unlockedCount / ${_badges.length} 획득',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: unlockedCount / _badges.length,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(List<_BadgeData> badges) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, i) {
        return _BadgeCell(
          badge: badges[i],
          index: i,
          onTap: () => _showBadgeDetail(badges[i]),
        );
      },
    );
  }

  void _showBadgeDetail(_BadgeData badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgeDetailSheet(badge: badge),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge cell
// ---------------------------------------------------------------------------
class _BadgeCell extends StatelessWidget {
  const _BadgeCell({required this.badge, required this.index, required this.onTap});

  final _BadgeData badge;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: badge.isCurrent
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: badge.isUnlocked
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 0.4, 0,
                          ]),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: badge.isUnlocked
                            ? badge.color.withOpacity(0.15)
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(badge.emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(badge.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: badge.isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (!badge.isUnlocked)
              Positioned(
                top: 6,
                right: 6,
                child: const Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondary),
              ),
            if (badge.isCurrent)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('진행중',
                      style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms).scale(begin: const Offset(0.9, 0.9));
  }
}

// ---------------------------------------------------------------------------
// Badge detail bottom sheet
// ---------------------------------------------------------------------------
class _BadgeDetailSheet extends StatelessWidget {
  const _BadgeDetailSheet({required this.badge});

  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: badge.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(badge.emoji, style: const TextStyle(fontSize: 42))),
          ),
          const SizedBox(height: 16),
          Text(badge.name,
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(badge.description,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? AppColors.successLight
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge.isUnlocked ? '획득 완료' : '미획득',
              style: AppTextStyles.labelMedium.copyWith(
                  color: badge.isUnlocked ? AppColors.success : AppColors.textSecondary,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class _BadgeData {
  final String emoji;
  final String name;
  final String description;
  final bool isUnlocked;
  final bool isCurrent;
  final Color color;

  const _BadgeData({
    required this.emoji,
    required this.name,
    required this.description,
    required this.isUnlocked,
    required this.isCurrent,
    required this.color,
  });
}
