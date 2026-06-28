/// All user-facing strings for StudyVerse.
/// Korean primary, English keys for reference.
abstract final class AppStrings {
  // ── App metadata ──────────────────────────────────────────────────────────
  static const String appName = 'StudyVerse';
  static const String appTagline = 'AI 공부 인증 & 리워드 플랫폼';
  static const String appDescription = '공부하고, 인증하고, 보상받자!';

  // ── Navigation ────────────────────────────────────────────────────────────
  static const String navHome = '홈';
  static const String navStatistics = '통계';
  static const String navStudy = '공부';
  static const String navCommunity = '커뮤니티';
  static const String navMyPage = '마이';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '로그인';
  static const String logout = '로그아웃';
  static const String register = '회원가입';
  static const String email = '이메일';
  static const String password = '비밀번호';
  static const String confirmPassword = '비밀번호 확인';
  static const String nickname = '닉네임';
  static const String forgotPassword = '비밀번호를 잊으셨나요?';
  static const String loginWithGoogle = 'Google로 로그인';
  static const String loginWithKakao = '카카오로 로그인';
  static const String loginWithApple = 'Apple로 로그인';
  static const String alreadyHaveAccount = '이미 계정이 있으신가요?';
  static const String dontHaveAccount = '계정이 없으신가요?';
  static const String agreeToTerms = '이용약관에 동의합니다';
  static const String agreeToPrivacy = '개인정보처리방침에 동의합니다';
  static const String loginSuccess = '로그인 성공!';
  static const String loginFailed = '로그인에 실패했습니다';
  static const String registerSuccess = '회원가입 성공! 환영합니다 🎉';
  static const String biometricAuth = '생체 인증으로 로그인';

  // ── Home ──────────────────────────────────────────────────────────────────
  static const String greeting = '안녕하세요';
  static const String todayStudyGoal = '오늘의 공부 목표';
  static const String startStudying = '공부 시작하기';
  static const String continueStudying = '공부 이어하기';
  static const String dailyChallenge = '오늘의 챌린지';
  static const String weeklyRanking = '이번 주 랭킹';
  static const String recentActivity = '최근 활동';
  static const String myStudyStreak = '공부 연속 달성';
  static const String days = '일';
  static const String hours = '시간';
  static const String minutes = '분';
  static const String seconds = '초';

  // ── Study ─────────────────────────────────────────────────────────────────
  static const String studyStart = 'AI 공부 시작';
  static const String studyCertification = '공부 인증 중';
  static const String studyTimer = '순공 타이머';
  static const String studyPause = '일시정지';
  static const String studyResume = '재개';
  static const String studyStop = '종료';
  static const String studyComplete = '공부 완료!';
  static const String pureStudyTime = '순공 시간';
  static const String totalStudyTime = '총 공부 시간';
  static const String aiMonitoring = 'AI 모니터링';
  static const String aiMonitoringActive = 'AI가 공부를 감지하고 있어요';
  static const String aiMonitoringInactive = 'AI 모니터링이 꺼져 있어요';
  static const String focusScore = '집중도';
  static const String certificationPhoto = '인증 사진';
  static const String takeCertificationPhoto = '인증 사진 찍기';
  static const String subjectSelect = '과목 선택';
  static const String studyGoalTime = '목표 시간';
  static const String breakTime = '휴식 시간';
  static const String pomodoroMode = '뽀모도로 모드';
  static const String deepFocusMode = '딥 포커스 모드';

  // ── Statistics ────────────────────────────────────────────────────────────
  static const String statistics = '통계';
  static const String weeklyStats = '주간 통계';
  static const String monthlyStats = '월간 통계';
  static const String totalStudyHours = '총 공부 시간';
  static const String averageDailyStudy = '일평균 공부량';
  static const String bestRecord = '최고 기록';
  static const String studyCalendar = '공부 캘린더';
  static const String subjectDistribution = '과목별 분포';
  static const String productivityChart = '생산성 차트';
  static const String streakRecord = '연속 달성 기록';

  // ── Community ─────────────────────────────────────────────────────────────
  static const String community = '커뮤니티';
  static const String crew = '크루';
  static const String mentor = '멘토';
  static const String myFeed = '내 피드';
  static const String following = '팔로잉';
  static const String followers = '팔로워';
  static const String createPost = '게시물 작성';
  static const String joinCrew = '크루 참여';
  static const String createCrew = '크루 만들기';
  static const String crewMembers = '크루원';
  static const String crewRanking = '크루 랭킹';
  static const String mentorRequest = '멘토 신청';
  static const String mentorSessions = '멘토링 세션';
  static const String like = '좋아요';
  static const String comment = '댓글';
  static const String share = '공유';
  static const String report = '신고';

  // ── Ranking ───────────────────────────────────────────────────────────────
  static const String ranking = '랭킹';
  static const String globalRanking = '전체 랭킹';
  static const String friendRanking = '친구 랭킹';
  static const String schoolRanking = '학교 랭킹';
  static const String myRank = '내 순위';

  // ── Rewards ───────────────────────────────────────────────────────────────
  static const String rewards = '리워드';
  static const String myPoints = '내 포인트';
  static const String badges = '배지';
  static const String achievements = '업적';
  static const String redeemReward = '리워드 교환';
  static const String pointHistory = '포인트 내역';
  static const String earnPoints = '포인트 적립';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = '프로필';
  static const String editProfile = '프로필 수정';
  static const String myBadges = '내 배지';
  static const String studyHistory = '공부 기록';
  static const String settings = '설정';
  static const String notification = '알림';
  static const String darkMode = '다크 모드';
  static const String language = '언어';
  static const String privacy = '개인정보';
  static const String terms = '이용약관';
  static const String help = '도움말';
  static const String version = '버전';
  static const String deleteAccount = '계정 삭제';

  // ── AI Coach ─────────────────────────────────────────────────────────────
  static const String aiCoach = 'AI 코치';
  static const String aiCoachGreeting = '안녕하세요! AI 코치입니다 👋';
  static const String askAiCoach = 'AI 코치에게 물어보기';
  static const String studyRecommendation = '공부 추천';
  static const String weaknessAnalysis = '취약점 분석';
  static const String studyPlan = '학습 계획';

  // ── Common ────────────────────────────────────────────────────────────────
  static const String confirm = '확인';
  static const String cancel = '취소';
  static const String save = '저장';
  static const String edit = '수정';
  static const String delete = '삭제';
  static const String next = '다음';
  static const String back = '이전';
  static const String skip = '건너뛰기';
  static const String done = '완료';
  static const String apply = '적용';
  static const String search = '검색';
  static const String filter = '필터';
  static const String sort = '정렬';
  static const String more = '더보기';
  static const String less = '접기';
  static const String loading = '불러오는 중...';
  static const String retry = '다시 시도';
  static const String refresh = '새로고침';
  static const String noData = '데이터가 없어요';
  static const String noInternet = '인터넷 연결을 확인해주세요';
  static const String serverError = '서버 오류가 발생했습니다';
  static const String unknownError = '알 수 없는 오류가 발생했습니다';
  static const String sessionExpired = '세션이 만료되었습니다. 다시 로그인해주세요.';

  // ── Permissions ───────────────────────────────────────────────────────────
  static const String permissionCamera = '카메라 권한이 필요합니다';
  static const String permissionCameraDesc = 'AI 공부 인증을 위해 카메라 접근 권한이 필요합니다.';
  static const String permissionMicrophone = '마이크 권한이 필요합니다';
  static const String permissionNotification = '알림 권한이 필요합니다';
  static const String permissionStorage = '저장소 권한이 필요합니다';
  static const String openSettings = '설정 열기';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const String onboarding1Title = '공부를 게임처럼!';
  static const String onboarding1Desc = 'AI가 여러분의 공부를 감지하고 포인트를 적립해드려요';
  static const String onboarding2Title = '함께 공부해요!';
  static const String onboarding2Desc = '크루를 만들고 친구들과 공부 랭킹을 겨루세요';
  static const String onboarding3Title = '보상을 받으세요!';
  static const String onboarding3Desc = '열심히 공부한 만큼 다양한 리워드를 받을 수 있어요';
  static const String getStarted = '시작하기';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String admin = '관리자';
  static const String userManagement = '사용자 관리';
  static const String contentManagement = '콘텐츠 관리';
  static const String analytics = '분석';
  static const String reports = '보고서';
}
