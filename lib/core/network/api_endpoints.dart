/// All API endpoint paths for StudyVerse backend.
abstract final class ApiEndpoints {
  // ── Base ──────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.studyverse.app';
  static const String apiVersion = '/v1';
  static const String _base = '$baseUrl$apiVersion';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String authBase = '$_base/auth';
  static const String login = '$authBase/login';
  static const String register = '$authBase/register';
  static const String logout = '$authBase/logout';
  static const String refreshToken = '$authBase/refresh';
  static const String forgotPassword = '$authBase/forgot-password';
  static const String resetPassword = '$authBase/reset-password';
  static const String verifyEmail = '$authBase/verify-email';
  static const String loginGoogle = '$authBase/google';
  static const String loginKakao = '$authBase/kakao';
  static const String loginApple = '$authBase/apple';

  // ── User / Profile ────────────────────────────────────────────────────────
  static const String userBase = '$_base/users';
  static const String me = '$userBase/me';
  static const String updateProfile = '$userBase/me';
  static const String updateAvatar = '$userBase/me/avatar';
  static const String changePassword = '$userBase/me/password';
  static const String deleteAccount = '$userBase/me';

  static String userProfile(String userId) => '$userBase/$userId';
  static String userFollowers(String userId) => '$userBase/$userId/followers';
  static String userFollowing(String userId) => '$userBase/$userId/following';
  static String followUser(String userId) => '$userBase/$userId/follow';
  static String unfollowUser(String userId) => '$userBase/$userId/unfollow';

  // ── Study Sessions ────────────────────────────────────────────────────────
  static const String studyBase = '$_base/study';
  static const String studySessions = '$studyBase/sessions';
  static const String studyStart = '$studyBase/sessions/start';
  static const String studyEnd = '$studyBase/sessions/end';
  static const String studyPause = '$studyBase/sessions/pause';
  static const String studyResume = '$studyBase/sessions/resume';

  static String studySession(String sessionId) =>
      '$studySessions/$sessionId';
  static String studySessionCertification(String sessionId) =>
      '$studySessions/$sessionId/certification';

  // ── AI / ML ───────────────────────────────────────────────────────────────
  static const String aiBase = '$_base/ai';
  static const String aiCoach = '$aiBase/coach';
  static const String aiCoachChat = '$aiBase/coach/chat';
  static const String aiAnalyze = '$aiBase/analyze';
  static const String aiStudyPlan = '$aiBase/study-plan';
  static const String aiWeaknessAnalysis = '$aiBase/weakness-analysis';
  static const String aiFaceVerify = '$aiBase/face/verify';
  static const String aiPoseDetect = '$aiBase/pose/detect';

  // ── Statistics ────────────────────────────────────────────────────────────
  static const String statsBase = '$_base/statistics';
  static const String statsDaily = '$statsBase/daily';
  static const String statsWeekly = '$statsBase/weekly';
  static const String statsMonthly = '$statsBase/monthly';
  static const String statsSubjects = '$statsBase/subjects';
  static const String statsStreak = '$statsBase/streak';
  static const String statsCalendar = '$statsBase/calendar';
  static const String statsProductivity = '$statsBase/productivity';

  // ── Ranking ───────────────────────────────────────────────────────────────
  static const String rankingBase = '$_base/rankings';
  static const String rankingGlobal = '$rankingBase/global';
  static const String rankingFriends = '$rankingBase/friends';
  static const String rankingSchool = '$rankingBase/school';
  static const String rankingCrew = '$rankingBase/crew';
  static const String myRank = '$rankingBase/me';

  // ── Community ─────────────────────────────────────────────────────────────
  static const String communityBase = '$_base/community';
  static const String posts = '$communityBase/posts';
  static const String feed = '$communityBase/feed';

  static String post(String postId) => '$posts/$postId';
  static String postLike(String postId) => '$posts/$postId/like';
  static String postComments(String postId) => '$posts/$postId/comments';
  static String postComment(String postId, String commentId) =>
      '$posts/$postId/comments/$commentId';

  // ── Crew ──────────────────────────────────────────────────────────────────
  static const String crewBase = '$_base/crews';
  static const String myCrews = '$crewBase/mine';

  static String crew(String crewId) => '$crewBase/$crewId';
  static String crewMembers(String crewId) => '$crewBase/$crewId/members';
  static String crewJoin(String crewId) => '$crewBase/$crewId/join';
  static String crewLeave(String crewId) => '$crewBase/$crewId/leave';
  static String crewRanking(String crewId) => '$crewBase/$crewId/ranking';

  // ── Mentor ────────────────────────────────────────────────────────────────
  static const String mentorBase = '$_base/mentors';
  static const String mentorSessions = '$mentorBase/sessions';

  static String mentor(String mentorId) => '$mentorBase/$mentorId';
  static String mentorRequest(String mentorId) =>
      '$mentorBase/$mentorId/request';

  // ── Rewards ───────────────────────────────────────────────────────────────
  static const String rewardBase = '$_base/rewards';
  static const String myPoints = '$rewardBase/points';
  static const String pointHistory = '$rewardBase/points/history';
  static const String badges = '$rewardBase/badges';
  static const String myBadges = '$rewardBase/badges/mine';
  static const String achievements = '$rewardBase/achievements';
  static const String myAchievements = '$rewardBase/achievements/mine';
  static const String rewardItems = '$rewardBase/items';

  static String redeemReward(String itemId) =>
      '$rewardBase/items/$itemId/redeem';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notificationBase = '$_base/notifications';
  static const String notifications = notificationBase;
  static const String notificationSettings = '$notificationBase/settings';
  static const String markAllRead = '$notificationBase/read-all';

  static String markRead(String notificationId) =>
      '$notificationBase/$notificationId/read';

  // ── Settings ──────────────────────────────────────────────────────────────
  static const String settingsBase = '$_base/settings';
  static const String appSettings = settingsBase;
  static const String studySettings = '$settingsBase/study';
  static const String privacySettings = '$settingsBase/privacy';
  static const String pushToken = '$settingsBase/push-token';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminBase = '$_base/admin';
  static const String adminUsers = '$adminBase/users';
  static const String adminContent = '$adminBase/content';
  static const String adminAnalytics = '$adminBase/analytics';
  static const String adminReports = '$adminBase/reports';

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const String health = '$_base/health';
  static const String version = '$_base/version';
  static const String upload = '$_base/upload';
}
