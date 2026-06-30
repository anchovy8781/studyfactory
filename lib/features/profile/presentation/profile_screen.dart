import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';
import 'package:studyverse/features/home/presentation/providers/home_provider.dart';

// ---------------------------------------------------------------------------
// Menu item model
// ---------------------------------------------------------------------------
class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String route;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.route,
  });
}

final _menuItems = [
  _MenuItem(
    icon: Icons.person_outline_rounded,
    iconColor: AppColors.primary,
    title: '내 정보',
    subtitle: '프로필 및 계정 정보',
    route: '/my/info',
  ),
  _MenuItem(
    icon: Icons.store_rounded,
    iconColor: AppColors.accent,
    title: '포인트 상점',
    subtitle: '포인트로 아이템 구매',
    route: '/store',
  ),
  _MenuItem(
    icon: Icons.style_rounded,
    iconColor: Color(0xFFE91E63),
    title: '푸드카드',
    subtitle: '확률형 카드 뽑기 & 도감',
    route: '/foodcard',
  ),
  _MenuItem(
    icon: Icons.history_rounded,
    iconColor: AppColors.success,
    title: '내 공부 기록',
    subtitle: '학습 히스토리 조회',
    route: '/statistics',
  ),
  _MenuItem(
    icon: Icons.show_chart_rounded,
    iconColor: Color(0xFF1A73E8),
    title: '과목 성적 향상도',
    subtitle: '시험 점수 추이 그래프',
    route: '/grade-graph',
  ),
  _MenuItem(
    icon: Icons.workspace_premium_rounded,
    iconColor: AppColors.warning,
    title: '내 뱃지',
    subtitle: '획득한 뱃지 보기',
    route: '/rewards/badges',
  ),
  _MenuItem(
    icon: Icons.celebration_rounded,
    iconColor: Color(0xFFFF6B35),
    title: '이벤트',
    subtitle: '진행 중인 이벤트 보기',
    route: '/events',
  ),
  _MenuItem(
    icon: Icons.person_add_alt_1_rounded,
    iconColor: Color(0xFF1DB954),
    title: '친구 초대하기',
    subtitle: '친구에게 StudyVerse 공유',
    route: 'share:invite',
  ),
  _MenuItem(
    icon: Icons.restaurant_rounded,
    iconColor: Color(0xFF00B894),
    title: '우리 학교 급식',
    subtitle: '오늘의 급식 메뉴 조회',
    route: '/meal',
  ),
  _MenuItem(
    icon: Icons.campaign_rounded,
    iconColor: const Color(0xFF9C27B0),
    title: '광고 센터',
    subtitle: '광고 보고 포인트 받기',
    route: '/ad-center',
  ),
  _MenuItem(
    icon: Icons.settings_outlined,
    iconColor: AppColors.textSecondary,
    title: '설정',
    route: '/my/settings',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final homeData = ref.watch(homeDataProvider);
    final nickname = user?.nickname ?? homeData?.userNickname ?? '사용자';
    final level = user?.level ?? 1;
    final points = user?.points ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('마이페이지', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(nickname, level, points),
            _buildStatsRow(homeData),
            const SizedBox(height: 12),
            _buildMenuList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Profile header ───────────────────────────────────────────────────────
  Widget _buildProfileHeader(String nickname, int level, int points) {
    final initial = nickname.isNotEmpty ? nickname.substring(0, 1) : 'S';
    // Simple XP model: each level needs level*1000 points to advance.
    final nextThreshold = level * 1000;
    final progress = (points / nextThreshold).clamp(0.0, 1.0);
    final remaining = (nextThreshold - points).clamp(0, nextThreshold);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppColors.cardShadow,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 14),
          Text(nickname,
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Lv. $level',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          // Level-up progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '레벨업까지 $remaining XP ($points / $nextThreshold)',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Stats row ────────────────────────────────────────────────────────────
  Widget _buildStatsRow(homeData) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildStatItem('순공 시간', homeData != null ? '${(homeData.todayStudyHours).toStringAsFixed(0)}h' : '-'),
            _buildStatDivider(),
            _buildStatItem('연속 학습', homeData != null ? '${homeData.streakDays}일' : '-'),
            _buildStatDivider(),
            _buildStatItem('오늘 점수', homeData != null ? '${homeData.focusScore.toInt()}점' : '-'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 3),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 36, color: AppColors.divider);
  }

  // ── Menu list ────────────────────────────────────────────────────────────
  Widget _buildMenuList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: List.generate(_menuItems.length, (i) {
          final item = _menuItems[i];
          return Column(
            children: [
              InkWell(
                onTap: () {
                  if (item.route == 'share:invite') {
                    Share.share(
                      'StudyVerse에서 함께 공부해요! 📚\n'
                      'AI 공부 인증·포모도로·랭킹까지 한 번에.\n'
                      '지금 StudyVerse를 시작해보세요!',
                      subject: 'StudyVerse 초대',
                    );
                    return;
                  }
                  try {
                    context.push(item.route);
                  } catch (_) {}
                },
                borderRadius: BorderRadius.circular(i == 0
                    ? 20
                    : i == _menuItems.length - 1
                        ? 20
                        : 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.iconColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.iconColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600)),
                            if (item.subtitle != null)
                              Text(item.subtitle!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (i * 50).ms),
              if (i < _menuItems.length - 1)
                const Divider(height: 1, color: AppColors.divider, indent: 70),
            ],
          );
        }),
      ),
    );
  }
}
