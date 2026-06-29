import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studyverse/core/router/route_names.dart';
import 'package:studyverse/shared/widgets/app_bottom_nav.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';

// AI Tools screen imports
import 'package:studyverse/features/ai_tools/presentation/ai_tools_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/ai_study_plan_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/ai_flashcard_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/ai_wrong_answer_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/ai_question_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/grade_simulation_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/ai_voice_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/ai_ocr_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/ai_mentor_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/pomodoro_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/forgetting_curve_screen.dart';
import 'package:studyverse/features/ai_tools/presentation/study_efficiency_screen.dart';

// Real screen imports
import 'package:studyverse/features/splash/presentation/splash_screen.dart';
import 'package:studyverse/features/auth/presentation/login_screen.dart';
import 'package:studyverse/features/auth/presentation/register_screen.dart';
import 'package:studyverse/features/auth/presentation/forgot_password_screen.dart';
import 'package:studyverse/features/legal/presentation/terms_screen.dart';
import 'package:studyverse/features/legal/data/legal_documents.dart';
import 'package:studyverse/features/home/presentation/home_screen.dart';
import 'package:studyverse/features/statistics/presentation/statistics_screen.dart';
import 'package:studyverse/features/calendar/presentation/calendar_screen.dart';
import 'package:studyverse/features/study/presentation/study_start_screen.dart';
import 'package:studyverse/features/study/presentation/study_certification_screen.dart';
import 'package:studyverse/features/study/presentation/study_timer_screen.dart';
import 'package:studyverse/features/community/presentation/community_screen.dart';
import 'package:studyverse/features/community/presentation/crew_screen.dart';
import 'package:studyverse/features/community/presentation/mentor_screen.dart';
import 'package:studyverse/features/profile/presentation/profile_screen.dart';
import 'package:studyverse/features/profile/presentation/my_info_screen.dart';
import 'package:studyverse/features/settings/presentation/settings_screen.dart';
import 'package:studyverse/features/ai_coach/presentation/ai_coach_screen.dart';
import 'package:studyverse/features/ranking/presentation/ranking_screen.dart';
import 'package:studyverse/features/rewards/presentation/rewards_screen.dart';
import 'package:studyverse/features/rewards/presentation/badges_screen.dart';
import 'package:studyverse/features/admin/presentation/admin_dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Slide transition helper
// ---------------------------------------------------------------------------

CustomTransitionPage<void> _slidePage(
  GoRouterState state,
  Widget child, {
  Offset begin = const Offset(1, 0),
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.5, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    ),
  );
}

CustomTransitionPage<void> _modalPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    fullscreenDialog: true,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// GoRouter
// ---------------------------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) => _globalRedirect(context, state, ref),
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('페이지를 찾을 수 없습니다', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => _slidePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        pageBuilder: (context, state) =>
            _slidePage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) =>
            _slidePage(state, const ForgotPasswordScreen()),
      ),

      // ── Legal documents ─────────────────────────────────────────────────
      GoRoute(
        path: '/terms',
        pageBuilder: (context, state) =>
            _slidePage(state, const TermsScreen(document: termsOfService)),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (context, state) =>
            _slidePage(state, const TermsScreen(document: privacyPolicy)),
      ),

      // ── Main shell (bottom nav) ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellScaffold(navigationShell: navigationShell),
        branches: [
          // 0 - Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // 1 - Statistics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.statistics,
                name: RouteNames.statistics,
                builder: (context, state) => const StatisticsScreen(),
                routes: [
                  GoRoute(
                    path: 'calendar',
                    name: RouteNames.calendar,
                    pageBuilder: (context, state) =>
                        _slidePage(state, const CalendarScreen()),
                  ),
                ],
              ),
            ],
          ),
          // 2 - Study (center tab)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.study,
                name: RouteNames.study,
                builder: (context, state) => const StudyStartScreen(),
              ),
            ],
          ),
          // 3 - Community
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.community,
                name: RouteNames.community,
                builder: (context, state) => const CommunityScreen(),
                routes: [
                  GoRoute(
                    path: 'crew',
                    name: RouteNames.crew,
                    pageBuilder: (context, state) =>
                        _slidePage(state, const CrewScreen()),
                  ),
                  GoRoute(
                    path: 'mentor',
                    name: RouteNames.mentor,
                    pageBuilder: (context, state) =>
                        _slidePage(state, const MentorScreen()),
                  ),
                ],
              ),
            ],
          ),
          // 4 - My Page
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.myPage,
                name: RouteNames.myPage,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'info',
                    name: RouteNames.profile,
                    pageBuilder: (context, state) =>
                        _slidePage(state, const MyInfoScreen()),
                  ),
                  GoRoute(
                    path: 'settings',
                    name: RouteNames.settings,
                    pageBuilder: (context, state) =>
                        _slidePage(state, const SettingsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Study flow (modal) ──────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.studyStart,
        name: RouteNames.studyStart,
        pageBuilder: (context, state) =>
            _modalPage(state, const StudyStartScreen()),
      ),
      GoRoute(
        path: RoutePaths.studyCertification,
        name: RouteNames.studyCertification,
        pageBuilder: (context, state) =>
            _modalPage(state, const StudyCertificationScreen()),
      ),
      GoRoute(
        path: RoutePaths.studyTimer,
        name: RouteNames.studyTimer,
        pageBuilder: (context, state) =>
            _modalPage(state, const StudyTimerScreen()),
      ),

      // ── AI Coach ────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.aiCoach,
        name: RouteNames.aiCoach,
        pageBuilder: (context, state) =>
            _slidePage(state, const AiCoachScreen()),
      ),

      // ── Ranking ─────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.ranking,
        name: RouteNames.ranking,
        pageBuilder: (context, state) =>
            _slidePage(state, const RankingScreen()),
      ),

      // ── Rewards ─────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.rewards,
        name: RouteNames.rewards,
        pageBuilder: (context, state) =>
            _slidePage(state, const RewardsScreen()),
        routes: [
          GoRoute(
            path: 'badges',
            name: RouteNames.badges,
            pageBuilder: (context, state) =>
                _slidePage(state, const BadgesScreen()),
          ),
        ],
      ),

      // ── Admin ───────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.admin,
        name: RouteNames.admin,
        pageBuilder: (context, state) =>
            _slidePage(state, const AdminDashboardScreen()),
      ),

      // ── AI Tools ────────────────────────────────────────────────────────
      GoRoute(
        path: '/ai-tools',
        pageBuilder: (context, state) =>
            _slidePage(state, const AiToolsScreen()),
        routes: [
          GoRoute(
            path: 'study-plan',
            pageBuilder: (context, state) =>
                _slidePage(state, const AiStudyPlanScreen()),
          ),
          GoRoute(
            path: 'wrong-answers',
            pageBuilder: (context, state) =>
                _slidePage(state, const AiWrongAnswerScreen()),
          ),
          GoRoute(
            path: 'flashcards',
            pageBuilder: (context, state) =>
                _slidePage(state, const AiFlashcardScreen()),
          ),
          GoRoute(
            path: 'questions',
            pageBuilder: (context, state) =>
                _slidePage(state, const AiQuestionScreen()),
          ),
          GoRoute(
            path: 'grade-sim',
            pageBuilder: (context, state) =>
                _slidePage(state, const GradeSimulationScreen()),
          ),
          GoRoute(
            path: 'voice',
            pageBuilder: (context, state) =>
                _slidePage(state, const AiVoiceScreen()),
          ),
          GoRoute(
            path: 'ocr',
            pageBuilder: (context, state) =>
                _slidePage(state, const AiOcrScreen()),
          ),
          GoRoute(
            path: 'mentor',
            pageBuilder: (context, state) =>
                _slidePage(state, const AiMentorScreen()),
          ),
          GoRoute(
            path: 'pomodoro',
            pageBuilder: (context, state) =>
                _slidePage(state, const PomodoroScreen()),
          ),
          GoRoute(
            path: 'forgetting-curve',
            pageBuilder: (context, state) =>
                _slidePage(state, const ForgettingCurveScreen()),
          ),
          GoRoute(
            path: 'efficiency',
            pageBuilder: (context, state) =>
                _slidePage(state, const StudyEfficiencyScreen()),
          ),
        ],
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Global redirect
// ---------------------------------------------------------------------------

String? _globalRedirect(BuildContext context, GoRouterState state, ProviderRef ref) {
  final authState = ref.read(authProvider);
  final location = state.matchedLocation;

  // Public routes that don't require auth
  const publicRoutes = [RoutePaths.splash, RoutePaths.login, RoutePaths.register];
  final isPublic = publicRoutes.any((r) => location == r);

  return authState.when(
    initial: () => null,
    loading: () => null,
    authenticated: (_) => isPublic && location != RoutePaths.splash ? RoutePaths.home : null,
    unauthenticated: () => isPublic ? null : RoutePaths.login,
    error: (_) => isPublic ? null : RoutePaths.login,
  );
}

// ---------------------------------------------------------------------------
// Shell scaffold
// ---------------------------------------------------------------------------

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder (only for truly unimplemented routes)
// ---------------------------------------------------------------------------

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 18))),
    );
  }
}
