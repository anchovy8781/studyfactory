import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studyverse/core/router/route_names.dart';
import 'package:studyverse/shared/widgets/app_bottom_nav.dart';

// ---------------------------------------------------------------------------
// Placeholder page builder (replace each with real page implementations)
// ---------------------------------------------------------------------------

Widget _placeholder(String title) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// GoRouter configuration
// ---------------------------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: _globalRedirect,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('페이지를 찾을 수 없습니다\n${state.error}'),
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
      // ── Splash / Onboarding ──────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => _placeholder('Splash'),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => _placeholder('Onboarding'),
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: _placeholder('Onboarding'),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => _placeholder('로그인'),
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: _placeholder('로그인'),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => _placeholder('회원가입'),
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: _placeholder('회원가입'),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => _placeholder('비밀번호 찾기'),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) => _placeholder('비밀번호 재설정'),
      ),

      // ── Main shell with bottom navigation ──────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShellScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => _placeholder('홈'),
              ),
            ],
          ),
          // Branch 1: Statistics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.statistics,
                name: RouteNames.statistics,
                builder: (context, state) => _placeholder('통계'),
                routes: [
                  GoRoute(
                    path: 'calendar',
                    name: RouteNames.calendar,
                    builder: (context, state) => _placeholder('공부 캘린더'),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Study (center FAB-style tab)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.study,
                name: RouteNames.study,
                builder: (context, state) => _placeholder('공부'),
              ),
            ],
          ),
          // Branch 3: Community
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.community,
                name: RouteNames.community,
                builder: (context, state) => _placeholder('커뮤니티'),
                routes: [
                  GoRoute(
                    path: 'feed',
                    name: RouteNames.communityFeed,
                    builder: (context, state) => _placeholder('피드'),
                  ),
                  GoRoute(
                    path: 'post/create',
                    name: RouteNames.createPost,
                    builder: (context, state) => _placeholder('게시물 작성'),
                  ),
                  GoRoute(
                    path: 'post/:postId',
                    name: RouteNames.communityPost,
                    builder: (context, state) {
                      final postId = state.pathParameters['postId']!;
                      return _placeholder('게시물 $postId');
                    },
                  ),
                  GoRoute(
                    path: 'crew',
                    name: RouteNames.crew,
                    builder: (context, state) => _placeholder('크루'),
                    routes: [
                      GoRoute(
                        path: 'create',
                        name: RouteNames.createCrew,
                        builder: (context, state) => _placeholder('크루 만들기'),
                      ),
                      GoRoute(
                        path: ':crewId',
                        name: RouteNames.crewDetail,
                        builder: (context, state) {
                          final crewId = state.pathParameters['crewId']!;
                          return _placeholder('크루 $crewId');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'mentor',
                    name: RouteNames.mentor,
                    builder: (context, state) => _placeholder('멘토'),
                    routes: [
                      GoRoute(
                        path: ':mentorId',
                        name: RouteNames.mentorDetail,
                        builder: (context, state) {
                          final mentorId = state.pathParameters['mentorId']!;
                          return _placeholder('멘토 $mentorId');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Branch 4: My Page
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.myPage,
                name: RouteNames.myPage,
                builder: (context, state) => _placeholder('마이'),
                routes: [
                  GoRoute(
                    path: 'profile',
                    name: RouteNames.profile,
                    builder: (context, state) => _placeholder('프로필'),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: RouteNames.editProfile,
                        builder: (context, state) =>
                            _placeholder('프로필 수정'),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    name: RouteNames.settings,
                    builder: (context, state) => _placeholder('설정'),
                    routes: [
                      GoRoute(
                        path: 'notifications',
                        name: RouteNames.notificationSettings,
                        builder: (context, state) =>
                            _placeholder('알림 설정'),
                      ),
                      GoRoute(
                        path: 'privacy',
                        name: RouteNames.privacySettings,
                        builder: (context, state) =>
                            _placeholder('개인정보 설정'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Top-level non-shell routes ─────────────────────────────────────────

      // Study flow (modal-style, not in bottom nav)
      GoRoute(
        path: RoutePaths.studyStart,
        name: RouteNames.studyStart,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          fullscreenDialog: true,
          child: _placeholder('AI 공부 시작'),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.studyCertification,
        name: RouteNames.studyCertification,
        builder: (context, state) => _placeholder('공부 인증 중'),
      ),
      GoRoute(
        path: RoutePaths.studyTimer,
        name: RouteNames.studyTimer,
        builder: (context, state) => _placeholder('순공 타이머'),
      ),
      GoRoute(
        path: RoutePaths.studyComplete,
        name: RouteNames.studyComplete,
        builder: (context, state) => _placeholder('공부 완료!'),
      ),
      GoRoute(
        path: RoutePaths.subjectSelect,
        name: RouteNames.subjectSelect,
        builder: (context, state) => _placeholder('과목 선택'),
      ),

      // AI Coach
      GoRoute(
        path: RoutePaths.aiCoach,
        name: RouteNames.aiCoach,
        builder: (context, state) => _placeholder('AI 코치'),
      ),

      // Ranking
      GoRoute(
        path: RoutePaths.ranking,
        name: RouteNames.ranking,
        builder: (context, state) => _placeholder('랭킹'),
      ),

      // Rewards
      GoRoute(
        path: RoutePaths.rewards,
        name: RouteNames.rewards,
        builder: (context, state) => _placeholder('리워드'),
        routes: [
          GoRoute(
            path: 'badges',
            name: RouteNames.badges,
            builder: (context, state) => _placeholder('배지'),
          ),
          GoRoute(
            path: 'achievements',
            name: RouteNames.achievements,
            builder: (context, state) => _placeholder('업적'),
          ),
        ],
      ),

      // Admin
      GoRoute(
        path: RoutePaths.admin,
        name: RouteNames.admin,
        builder: (context, state) => _placeholder('관리자'),
        routes: [
          GoRoute(
            path: 'users',
            name: RouteNames.adminUsers,
            builder: (context, state) => _placeholder('사용자 관리'),
          ),
          GoRoute(
            path: 'content',
            name: RouteNames.adminContent,
            builder: (context, state) => _placeholder('콘텐츠 관리'),
          ),
          GoRoute(
            path: 'analytics',
            name: RouteNames.adminAnalytics,
            builder: (context, state) => _placeholder('분석'),
          ),
        ],
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Global redirect (auth guard)
// ---------------------------------------------------------------------------

String? _globalRedirect(BuildContext context, GoRouterState state) {
  // TODO: Inject auth state via Riverpod.
  // For now, skip all redirects so the app can navigate freely during dev.
  return null;
}

// ---------------------------------------------------------------------------
// Shell scaffold with bottom navigation
// ---------------------------------------------------------------------------

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

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
