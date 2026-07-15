class ApiConstants {
  const ApiConstants._();

  // API version prefix
  static const apiPrefix = '/api/v1';
  
  // Base paths
  static const basePath = '/api';
  static const symptomsPath = '$basePath/symptoms';
  static const predictionPath = '$basePath/predict';
  
  // Authentication endpoints
  static const authPath = '$apiPrefix/auth';
  static const loginPath = '$authPath/login';
  static const registerPath = '$authPath/register';
  static const logoutPath = '$authPath/logout';
  static const refreshTokenPath = '$authPath/refresh';
  static const verifyEmailPath = '$authPath/verify-email';
  static const forgotPasswordPath = '$authPath/forgot-password';
  static const resetPasswordPath = '$authPath/reset-password';
  
  // User endpoints
  static const usersPath = '$apiPrefix/users';
  static const userMePath = '$usersPath/me';
  static const userProfilePath = '$usersPath/profile';
  static const userAddressPath = '$usersPath/address';
  static const userEmergencyContactPath = '$usersPath/emergency-contact';
  static const userMedicalInfoPath = '$usersPath/medical-info';
  
  // Symptom Checker endpoints
  static const symptomCheckerPath = '$apiPrefix/symptom-checker';
  static const symptomCheckPredictPath = '$symptomCheckerPath/predict';
  static const symptomCheckSymptomsPath = '$symptomCheckerPath/symptoms';
  static const symptomCheckDiseasesPath = '$symptomCheckerPath/diseases';
  static const symptomCheckHealthPath = '$symptomCheckerPath/health';
  
  // Medical Chatbot endpoints
  static const chatbotPath = '$apiPrefix/chatbot';
  static const chatbotChatPath = '$chatbotPath/chat';
  static const chatbotConversationsPath = '$chatbotPath/conversations';
  static const chatbotFeedbackPath = '$chatbotPath/feedback';
  static const chatbotHealthPath = '$chatbotPath/health';
  
  // Emergency endpoints
  static const emergencyPath = '$apiPrefix/emergency';
  static const emergencyAssessmentPath = '$emergencyPath/assessment';
  static const emergencyHistoryPath = '$emergencyPath/history';
  static const emergencyContactsPath = '$emergencyPath/contacts';
  static const emergencySosPath = '$emergencyPath/sos';
  static const emergencyFirstAidPath = '$emergencyPath/first-aid';
  static const emergencyHealthPath = '$emergencyPath/health';

  /// Builds the URL for a specific assessment: GET /api/v1/emergency/assessment/{id}
  static String emergencyAssessmentById(String id) => '$emergencyAssessmentPath/$id';

  /// Builds the URL for a specific contact: PUT/DELETE /api/v1/emergency/contacts/{id}
  static String emergencyContactById(String id) => '$emergencyContactsPath/$id';

  // Health Education endpoints
  static const educationPath            = '$apiPrefix/education';
  static const educationDashboardPath   = '$educationPath/dashboard';
  static const educationCategoriesPath  = '$educationPath/categories';
  static const educationArticlesPath    = '$educationPath/articles';
  static const educationFeaturedPath    = '$educationPath/featured';
  static const educationSearchPath      = '$educationPath/search';
  static const educationRecommendPath   = '$educationPath/recommendations';
  static const educationBookmarksPath   = '$educationPath/bookmarks';
  static const educationReadProgressPath = '$educationPath/reading-progress';

  static String educationArticleById(String id) => '$educationArticlesPath/$id';
  static String educationBookmarkById(String id) => '$educationBookmarksPath/$id';
  static String educationReadProgress(String id) => '$educationReadProgressPath/$id';

  // Health check
  static const healthPath = '/health';
}
