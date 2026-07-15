import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../features/authentication/presentation/pages/forgot_password_page.dart';
import '../features/authentication/presentation/pages/guest_mode_page.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/onboarding_page.dart';
import '../features/authentication/presentation/pages/otp_verification_page.dart';
import '../features/authentication/presentation/pages/profile_completion_page.dart';
import '../features/authentication/presentation/pages/register_page.dart';
import '../features/authentication/presentation/pages/reset_password_page.dart';
import '../features/authentication/presentation/pages/splash_page.dart';
import '../features/authentication/presentation/pages/welcome_page.dart';
import '../features/disease_prediction/presentation/pages/disease_prediction_home_page.dart';
import '../features/emergency/presentation/pages/emergency_page.dart';
import '../features/health_education/presentation/pages/health_education_page.dart';
import '../features/health_education/presentation/pages/article_list_page.dart';
import '../features/health_education/presentation/pages/article_detail_page.dart';
import '../features/health_education/presentation/pages/bookmarks_page.dart';
import '../features/health_education/domain/entities/health_article.dart';
import '../features/health_education/domain/entities/health_category.dart';
// ── Medical Records pages ──────────────────────────────────────────────────
import '../features/health_records/presentation/pages/health_records_page.dart';
import '../features/health_records/presentation/pages/lab_reports_page.dart';
import '../features/health_records/presentation/pages/medical_history_page.dart';
import '../features/health_records/presentation/pages/medical_images_page.dart';
import '../features/health_records/presentation/pages/medical_profile_page.dart';
import '../features/health_records/presentation/pages/medical_records_page.dart';
import '../features/health_records/presentation/pages/medical_timeline_page.dart';
import '../features/health_records/presentation/pages/prescriptions_page.dart';
import '../features/health_records/presentation/pages/search_records_page.dart';
import '../features/health_records/presentation/pages/upload_report_page.dart';
// ─────────────────────────────────────────────────────────────────────────
import '../features/home/presentation/pages/home_dashboard_page.dart';
import '../features/medical_chatbot/presentation/pages/chatbot_home_page.dart';
import '../features/nearby_healthcare/presentation/pages/nearby_healthcare_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/symptom_checker/domain/entities/prediction.dart';
import '../features/symptom_checker/presentation/pages/history_page.dart';
import '../features/symptom_checker/presentation/pages/prediction_page.dart';
import '../features/symptom_checker/presentation/pages/symptom_checker_page.dart';
// ── Offline module pages ───────────────────────────────────────────────────
import '../features/offline/presentation/pages/offline_dashboard_page.dart';
import '../features/offline/presentation/pages/offline_symptom_checker_page.dart';
import '../features/offline/presentation/pages/offline_chatbot_page.dart';
import '../features/offline/presentation/pages/sync_center_page.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final isAuthRoute = _authRoutes.contains(settings.name);

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: Duration(milliseconds: isAuthRoute ? 320 : 280),
      reverseTransitionDuration:
          Duration(milliseconds: isAuthRoute ? 260 : 220),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _buildPage(settings),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (isAuthRoute) {
          return FadeTransition(opacity: animation, child: child);
        }
        // Medical Records sub-pages slide up from bottom for a sheet-like feel.
        if (_recordsSubRoutes.contains(settings.name)) {
          final tween =
              Tween(begin: const Offset(0.0, 0.08), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
                position: animation.drive(tween), child: child),
          );
        }
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static const _authRoutes = {
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.welcome,
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
    RouteNames.otpVerification,
    RouteNames.resetPassword,
    RouteNames.profileCompletion,
    RouteNames.guestMode,
  };

  /// Medical Records sub-pages use a soft fade+slide-up transition.
  static const _recordsSubRoutes = {
    RouteNames.medicalProfile,
    RouteNames.medicalHistory,
    RouteNames.prescriptions,
    RouteNames.medicalImages,
    RouteNames.medicalTimeline,
    RouteNames.searchRecords,
    RouteNames.uploadReport,
    RouteNames.labReports,
    RouteNames.allRecords,
    // Health Education sub-pages use the same transition
    RouteNames.articleList,
    RouteNames.articleDetail,
    RouteNames.eduBookmarks,
    // Offline sub-pages
    RouteNames.offlineSymptoms,
    RouteNames.offlineChatbot,
    RouteNames.syncCenter,
  };

  static Widget _buildPage(RouteSettings settings) {
    return switch (settings.name) {
      // ── Auth ──────────────────────────────────────────────────────────────
      RouteNames.splash             => const AuthSplashPage(),
      RouteNames.onboarding         => const OnboardingPage(),
      RouteNames.welcome            => const WelcomePage(),
      RouteNames.login              => const LoginPage(),
      RouteNames.register           => const RegisterPage(),
      RouteNames.forgotPassword     => const ForgotPasswordPage(),
      RouteNames.otpVerification    => const OtpVerificationPage(),
      RouteNames.resetPassword      => const ResetPasswordPage(),
      RouteNames.profileCompletion  => const ProfileCompletionPage(),
      RouteNames.guestMode          => const GuestModePage(),

      // ── Core app ──────────────────────────────────────────────────────────
      RouteNames.home               => const HomeDashboardPage(),
      RouteNames.symptomChecker     => const SymptomCheckerPage(),
      RouteNames.history            => const HistoryPage(),
      RouteNames.chatbot            => const ChatbotHomePage(),
      RouteNames.diseasePrediction  => const DiseasePredictionHomePage(),
      RouteNames.emergency          => const EmergencyPage(),
      RouteNames.nearbyHealthcare   => const NearbyHealthcarePage(),
      RouteNames.profile            => const ProfilePage(),
      RouteNames.settings           => const SettingsPage(),
      RouteNames.healthEducation    => const HealthEducationPage(),

      // ── Offline Module ─────────────────────────────────────────────────────
      RouteNames.offlineDashboard   => const OfflineDashboardPage(),
      RouteNames.offlineSymptoms    => const OfflineSymptomCheckerPage(),
      RouteNames.offlineChatbot     => const OfflineChatbotPage(),
      RouteNames.syncCenter         => const SyncCenterPage(),

      // ── Health Education sub-pages ─────────────────────────────────────────
      RouteNames.articleList        => ArticleListPage(
          initialCategory: settings.arguments is HealthCategory
              ? settings.arguments as HealthCategory
              : null,
        ),
      RouteNames.articleDetail      => ArticleDetailPage(
          previewArticle: settings.arguments is HealthArticle
              ? settings.arguments as HealthArticle
              : _emptyArticle(),
        ),
      RouteNames.eduBookmarks       => const BookmarksPage(),

      RouteNames.prediction         => PredictionPage(
          prediction: settings.arguments is Prediction
              ? settings.arguments! as Prediction
              : Prediction.empty(),
        ),

      // ── Medical Records (PHR) ──────────────────────────────────────────────
      RouteNames.healthRecords      => const HealthRecordsPage(),
      RouteNames.medicalProfile     => const MedicalProfilePage(),
      RouteNames.medicalHistory     => const MedicalHistoryPage(),
      RouteNames.prescriptions      => const PrescriptionsPage(),
      RouteNames.medicalImages      => const MedicalImagesPage(),
      RouteNames.medicalTimeline    => const MedicalTimelinePage(),
      RouteNames.searchRecords      => const SearchRecordsPage(),
      RouteNames.uploadReport       => const UploadReportPage(),
      RouteNames.labReports         => const LabReportsPage(),
      RouteNames.allRecords         => const MedicalRecordsPage(),

      _                             => const _NotFoundPage(),
    };
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: const Center(child: Text('Page not found')),
    );
  }
}

HealthArticle _emptyArticle() => HealthArticle(
      id: '',
      title: '',
      slug: '',
      language: 'en',
      readTimeMin: 0,
      tags: [],
      isFeatured: false,
      viewCount: 0,
      bookmarkCount: 0,
    );
