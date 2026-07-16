class RouteNames {
  const RouteNames._();

  // ── Auth flow ──────────────────────────────────────────────────────────────
  static const splash             = '/';
  static const onboarding         = '/onboarding';
  static const welcome            = '/welcome';
  static const login              = '/login';
  static const register           = '/register';
  static const forgotPassword     = '/forgot-password';
  static const otpVerification    = '/otp-verification';
  static const resetPassword      = '/reset-password';
  static const profileCompletion  = '/profile-completion';
  static const guestMode          = '/guest-mode';

  // ── App ────────────────────────────────────────────────────────────────────
  static const home               = '/home';
  static const symptomChecker     = '/symptom-checker';
  static const chatbot            = '/chatbot';
  static const emergency          = '/emergency';
  static const diseasePrediction  = '/disease-prediction';
  static const prediction         = '/prediction';
  static const history            = '/history';
  static const profile            = '/profile';
  static const settings           = '/settings';
  static const healthEducation    = '/health-education';

  // ── Health Education sub-pages ─────────────────────────────────────────────
  static const articleList        = '/health-education/articles';
  static const articleDetail      = '/health-education/article';
  static const eduBookmarks       = '/health-education/bookmarks';

  // ── Offline Module ─────────────────────────────────────────────────────────
  static const offlineDashboard   = '/offline';
  static const offlineSymptoms    = '/offline/symptoms';
  static const offlineChatbot     = '/offline/chatbot';
  static const syncCenter         = '/offline/sync';

  // ── Medical Records (PHR) ──────────────────────────────────────────────────
  static const healthRecords      = '/records';
  static const medicalProfile     = '/records/profile';
  static const medicalHistory     = '/records/history';
  static const prescriptions      = '/records/prescriptions';
  static const medicalImages      = '/records/images';
  static const medicalTimeline    = '/records/timeline';
  static const searchRecords      = '/records/search';
  static const uploadReport       = '/records/upload';
  static const labReports         = '/records/labs';
  static const allRecords         = '/records/all';

  // ── Notifications ──────────────────────────────────────────────────────────
  static const notifications      = '/notifications';
}
