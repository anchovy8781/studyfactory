import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';
import 'package:studyverse/shared/widgets/app_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/core/services/ai_config_service.dart';
import 'package:studyverse/core/services/rewards_service.dart';
import 'package:studyverse/core/services/notification_service.dart';
import 'package:studyverse/features/onboarding/presentation/onboarding_screen.dart' show onboardingDoneKey;
import 'package:studyverse/features/home/domain/models/home_model.dart';
import 'package:studyverse/features/home/presentation/providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Pull the server-managed Gemini key so AI tools work without manual entry.
    AiConfigService.syncKey();
    // Daily streak reward + claim any pending referral rewards.
    _runDailyRewards();
    // First-launch onboarding (5 study-habit questions).
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOnboard());
  }

  Future<void> _maybeOnboard() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(onboardingDoneKey) ?? false;
    if (!done && mounted) context.go('/onboarding');
  }

  Future<void> _runDailyRewards() async {
    final awarded = await RewardsService.instance.checkDailyStreak();
    if (awarded) {
      await NotificationService.instance
          .notify('연속 학습 보상 🔥', '오늘의 연속 학습 보상 15포인트가 지급되었습니다!');
    }
    // Ensure fresh home data before deciding on the streak warning.
    await ref.read(homeProvider.notifier).refresh();
    // 연속학습 경고: 오늘 공부 기록이 없으면 자정 1시간 전(23시)에 1회 경고 알림.
    final data = ref.read(homeDataProvider);
    if (data != null && data.todayStudyHours <= 0) {
      await NotificationService.instance.scheduleStreakWarning();
    } else {
      await NotificationService.instance.cancelStreakWarning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    // No bottomNavigationBar here — the shell (AppShellScaffold) provides the
    // single shared bottom navigation. A second one here caused two bars.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: homeState.when(
        initial: () => const _LoadingView(),
        loading: () => const _LoadingView(),
        loaded: (data) => _HomeContent(
          data: data,
          onStartStudy: () => context.push('/study/start'),
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        ),
        error: (msg) => _ErrorView(message: msg, onRetry: () => ref.read(homeProvider.notifier).refresh()),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.data,
    required this.onStartStudy,
    required this.onRefresh,
  });

  final HomeData data;
  final VoidCallback onStartStudy;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingPageHorizontal,
              0,
              AppSizes.paddingPageHorizontal,
              AppSizes.space3xl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSizes.spaceLg),
                _buildGreeting(),
                const SizedBox(height: AppSizes.spaceLg),
                _buildStudyTimeCard(),
                const SizedBox(height: AppSizes.spaceLg),
                _buildStreakAndPoints(context),
                const SizedBox(height: AppSizes.spaceLg),
                _buildAiCard(context),
                const SizedBox(height: AppSizes.spaceLg),
                _buildAiToolsSection(context),
                const SizedBox(height: AppSizes.spaceLg),
                _buildQuickStats(),
                const SizedBox(height: AppSizes.spaceLg),
                _buildTodayTips(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      floating: true,
      pinned: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSizes.spaceLg),
        child: Image.asset(
          'assets/images/logo.png',
          width: 32,
          height: 32,
          errorBuilder: (_, __, ___) => Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'StudyVerse',
        style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
      ),
      actions: [
        // Points chip
        Container(
          margin: const EdgeInsets.only(right: AppSizes.spaceSm),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMd, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                '${_formatNumber(data.points)}P',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        // Profile
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.spaceLg),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  data.userNickname.isNotEmpty ? data.userNickname[0] : '?',
                  style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 6
        ? '좋은 새벽이에요,'
        : hour < 12
            ? '좋은 아침이에요,'
            : hour < 18
                ? '안녕하세요,'
                : '수고하셨어요,';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting ${data.userNickname}님!',
          style: AppTextStyles.headlineSmall,
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.05, end: 0),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          '오늘도 화이팅이에요! 🔥',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent),
        ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
      ],
    );
  }

  Widget _buildStudyTimeCard() {
    final hours = data.todayStudyHours.floor();
    final minutes = ((data.todayStudyHours - hours) * 60).round();
    final progress = (data.todayStudyHours / data.targetHours).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(Icons.timer_rounded, color: AppColors.primary, size: AppSizes.iconLg),
              ),
              const SizedBox(width: AppSizes.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('오늘 순공 시간', style: AppTextStyles.labelMedium),
                  Text(
                    '목표 ${data.targetHours.toStringAsFixed(0)}시간',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm, vertical: 4),
                decoration: BoxDecoration(
                  color: percent >= 100 ? AppColors.successLight : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
                child: Text(
                  '$percent%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: percent >= 100 ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLg),

          // Large time display
          ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: Text(
              '${hours}시간 ${minutes}분',
              style: AppTextStyles.displaySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: AppSizes.spaceLg),

          // Progress bar
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .custom(
                    duration: 1200.ms,
                    delay: 400.ms,
                    curve: Curves.easeOut,
                    builder: (_, value, child) => FractionallySizedBox(
                      widthFactor: progress * value,
                      child: child,
                    ),
                  ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${hours}h ${minutes}m 완료',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
              Text(
                '목표까지 ${(data.targetHours - data.todayStudyHours).clamp(0, double.infinity).toStringAsFixed(1)}h 남음',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 150.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildStreakAndPoints(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/streak'),
            child: _Card(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: AppSizes.spaceXs),
                      Text(
                        '연속 학습',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentDark),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppColors.accentDark.withOpacity(0.6)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    '${data.streakDays}일',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '최고 ${data.bestStreak}일',
                    style: AppTextStyles.caption.copyWith(color: AppColors.accentDark.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spaceMd),
        Expanded(
          child: _Card(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 22),
                    const SizedBox(width: AppSizes.spaceXs),
                    Text(
                      '포인트',
                      style: AppTextStyles.labelSmall.copyWith(color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Text(
                  _formatNumber(data.points),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'P 포인트',
                  style: AppTextStyles.caption.copyWith(color: Color(0xFF2E7D32).withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 250.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildAiCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.primaryShadow,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingCardLg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.psychology_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'AI 공부 인증',
                        style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spaceMd),
                Text(
                  data.isStudying ? 'AI 인증 모니터링 중...' : '지금 공부를\n시작해보세요!',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white, height: 1.3),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Text(
                  data.isStudying
                      ? '실시간으로 공부 인증이 진행 중입니다'
                      : '카메라로 AI가 공부를 인증합니다',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: AppSizes.spaceLg),
                GestureDetector(
                  onTap: () => context.push('/study/start'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spaceLg,
                      vertical: AppSizes.spaceMd,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.isStudying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          color: AppColors.primary,
                          size: AppSizes.iconLg,
                        ),
                        const SizedBox(width: AppSizes.spaceSm),
                        Text(
                          data.isStudying ? '공부 현황 보기' : '공부 시작',
                          style: AppTextStyles.buttonSmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spaceLg),
          const AppLogo(size: AppSizes.characterMd),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 330.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildAiToolsSection(BuildContext context) {
    final tools = [
      (Icons.auto_stories_rounded, '학습 계획', '/ai-tools/study-plan', const Color(0xFF6366F1)),
      (Icons.style_rounded, '플래시카드', '/ai-tools/flashcards', const Color(0xFF10B981)),
      (Icons.quiz_rounded, '예상문제', '/ai-tools/questions', const Color(0xFFF59E0B)),
      (Icons.timer_rounded, '포모도로', '/ai-tools/pomodoro', const Color(0xFF14B8A6)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('AI 학습 도구', style: AppTextStyles.titleMedium),
            GestureDetector(
              onTap: () => context.push('/ai-tools'),
              child: Text('전체보기', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceMd),
        Row(
          children: tools.map((t) {
            final (icon, label, route, color) = t;
            return Expanded(
              child: GestureDetector(
                onTap: () => context.push(route),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 450.ms);
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('오늘의 통계', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSizes.spaceMd),
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.track_changes_rounded,
                label: '집중도',
                value: '${data.focusScore.toStringAsFixed(0)}%',
                color: AppColors.primary,
                backgroundColor: AppColors.primaryContainer,
              ),
            ),
            const SizedBox(width: AppSizes.spaceSm),
            Expanded(
              child: _StatChip(
                icon: Icons.library_books_rounded,
                label: '최근 세션',
                value: '${data.recentSessions}회',
                color: AppColors.accent,
                backgroundColor: AppColors.accentLight,
              ),
            ),
            const SizedBox(width: AppSizes.spaceSm),
            Expanded(
              child: _StatChip(
                icon: Icons.local_fire_department_rounded,
                label: '연속 일수',
                value: '${data.streakDays}일',
                color: const Color(0xFFFF6B00),
                backgroundColor: const Color(0xFFFFF3E0),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildTodayTips() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSizes.spaceSm),
              Text('오늘의 학습 팁', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Text(
            _dailyTip(),
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 480.ms);
  }

  /// A study tip that changes every day (deterministic by day-of-year).
  static String _dailyTip() {
    const tips = [
      '포모도로 기법을 활용해보세요!\n25분 집중 후 5분 휴식을 반복하면\n집중력이 크게 향상됩니다.',
      '배운 내용을 다른 사람에게 설명하듯\n말해보면 기억에 훨씬 오래 남아요.',
      '잠들기 전 10분 복습은\n장기 기억 형성에 큰 도움이 됩니다.',
      '어려운 과목을 오전에 배치하면\n집중력이 높을 때 효율적으로 공부할 수 있어요.',
      '한 번에 몰아서보다 매일 조금씩\n나눠서 공부하는 분산 학습이 더 효과적입니다.',
      '공부 시작 전 오늘의 목표를\n구체적으로 적어두면 집중이 쉬워져요.',
      '스마트폰은 다른 방에 두고\n공부하면 집중 시간이 길어집니다.',
      '틀린 문제는 오답노트에 정리해\n약점을 집중적으로 보완해보세요.',
      '충분한 수면은 최고의 학습 도구입니다.\n하루 7시간 이상 자도록 노력해보세요.',
      '물을 자주 마시고 가벼운 스트레칭을 하면\n뇌가 더 잘 작동해요.',
      '복습은 망각곡선을 따라\n1일·3일·7일 간격으로 하면 효과적입니다.',
      '작은 목표를 달성할 때마다\n스스로에게 보상을 주면 동기가 유지돼요.',
      '공부 환경을 깔끔하게 정리하면\n불필요한 주의 분산을 줄일 수 있어요.',
      '이해가 안 되는 부분은 넘기지 말고\nAI 멘토에게 바로 질문해보세요.',
    ];
    final now = DateTime.now();
    final doy = now.difference(DateTime(now.year)).inDays;
    return tips[doy % tips.length];
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child, this.gradient, this.padding});

  final Widget child;
  final LinearGradient? gradient;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSizes.paddingCardLg),
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spaceMd,
        horizontal: AppSizes.spaceMd,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconLg),
          const SizedBox(height: AppSizes.spaceXs),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSizes.spaceLg),
          Text('데이터 불러오는 중...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 56),
            const SizedBox(height: AppSizes.spaceLg),
            Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.spaceXl),
            AppButton(label: '다시 시도', onPressed: onRetry, isFullWidth: false),
          ],
        ),
      ),
    );
  }
}
