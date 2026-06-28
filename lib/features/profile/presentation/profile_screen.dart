import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    route: '/profile/info',
  ),
  _MenuItem(
    icon: Icons.history_rounded,
    iconColor: AppColors.success,
    title: '내 공부 기록',
    subtitle: '학습 히스토리 조회',
    route: '/statistics',
  ),
  _MenuItem(
    icon: Icons.workspace_premium_rounded,
    iconColor: AppColors.warning,
    title: '내 뱃지',
    subtitle: '획득한 뱃지 보기',
    route: '/badges',
  ),
  _MenuItem(
    icon: Icons.people_outline_rounded,
    iconColor: const Color(0xFF9C27B0),
    title: '내 네트워크',
    subtitle: '친구 및 팔로잉',
    route: '/network',
  ),
  _MenuItem(
    icon: Icons.card_giftcard_rounded,
    iconColor: AppColors.accent,
    title: '친구 초대하기',
    subtitle: '초대하면 포인트 지급!',
    route: '/invite',
  ),
  _MenuItem(
    icon: Icons.settings_outlined,
    iconColor: AppColors.textSecondary,
    title: '설정',
    route: '/settings',
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
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(nickname),
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
  Widget _buildProfileHeader(String nickname) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: AppColors.surface,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Center(child: Text('🐶', style: TextStyle(fontSize: 44))),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
              ),
            ],
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
              'Lv. 25 · 공부가 인생의 무기',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
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
