/// Named route constants used by GoRouter throughout the app.
abstract final class RouteNames {
  // ── Shell / root ──────────────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';

  // ── Main shell (bottom nav) ───────────────────────────────────────────────
  static const String home = 'home';
  static const String statistics = 'statistics';
  static const String study = 'study';
  static const String community = 'community';
  static const String myPage = 'my-page';

  // ── Study sub-routes ──────────────────────────────────────────────────────
  static const String studyStart = 'study-start';
  static const String studyCertification = 'study-certification';
  static const String studyTimer = 'study-timer';
  static const String studyComplete = 'study-complete';
  static const String subjectSelect = 'subject-select';

  // ── AI ────────────────────────────────────────────────────────────────────
  static const String aiCoach = 'ai-coach';

  // ── Stats sub-routes ──────────────────────────────────────────────────────
  static const String calendar = 'calendar';

  // ── Community sub-routes ──────────────────────────────────────────────────
  static const String communityFeed = 'community-feed';
  static const String communityPost = 'community-post';
  static const String createPost = 'create-post';
  static const String crew = 'crew';
  static const String crewDetail = 'crew-detail';
  static const String createCrew = 'create-crew';
  static const String mentor = 'mentor';
  static const String mentorDetail = 'mentor-detail';

  // ── Ranking ───────────────────────────────────────────────────────────────
  static const String ranking = 'ranking';

  // ── Rewards ───────────────────────────────────────────────────────────────
  static const String rewards = 'rewards';
  static const String badges = 'badges';
  static const String achievements = 'achievements';

  // ── Profile / Settings ────────────────────────────────────────────────────
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
  static const String settings = 'settings';
  static const String notificationSettings = 'notification-settings';
  static const String privacySettings = 'privacy-settings';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String admin = 'admin';
  static const String adminUsers = 'admin-users';
  static const String adminContent = 'admin-content';
  static const String adminAnalytics = 'admin-analytics';
}

/// Path constants matching the GoRouter location strings.
abstract final class RoutePaths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Shell paths
  static const String home = '/home';
  static const String statistics = '/statistics';
  static const String study = '/study';
  static const String community = '/community';
  static const String myPage = '/my';

  // Study
  static const String studyStart = '/study/start';
  static const String studyCertification = '/study/certification';
  static const String studyTimer = '/study/timer';
  static const String studyComplete = '/study/complete';
  static const String subjectSelect = '/study/subject';

  // AI
  static const String aiCoach = '/ai-coach';

  // Stats
  static const String calendar = '/statistics/calendar';

  // Community
  static const String communityFeed = '/community/feed';
  static const String createPost = '/community/post/create';
  static String communityPost(String postId) => '/community/post/$postId';
  static const String crew = '/community/crew';
  static String crewDetail(String crewId) => '/community/crew/$crewId';
  static const String createCrew = '/community/crew/create';
  static const String mentor = '/community/mentor';
  static String mentorDetail(String mentorId) =>
      '/community/mentor/$mentorId';

  // Ranking
  static const String ranking = '/ranking';

  // Rewards
  static const String rewards = '/rewards';
  static const String badges = '/rewards/badges';
  static const String achievements = '/rewards/achievements';

  // Profile
  static const String profile = '/my/profile';
  static const String editProfile = '/my/profile/edit';
  static const String settings = '/my/settings';
  static const String notificationSettings = '/my/settings/notifications';
  static const String privacySettings = '/my/settings/privacy';

  // Admin
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminContent = '/admin/content';
  static const String adminAnalytics = '/admin/analytics';
}
