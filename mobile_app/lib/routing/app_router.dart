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
import '../features/health_records/presentation/pages/health_records_page.dart';
import '../features/home/presentation/pages/home_dashboard_page.dart';
import '../features/medical_chatbot/presentation/pages/chatbot_home_page.dart';
import '../features/nearby_healthcare/presentation/pages/nearby_healthcare_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/symptom_checker/domain/entities/prediction.dart';
import '../features/symptom_checker/presentation/pages/history_page.dart';
import '../features/symptom_checker/presentation/pages/prediction_page.dart';
import '../features/symptom_checker/presentation/pages/symptom_checker_page.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Auth pages use a fade transition for a softer feel.
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

      // ── App ───────────────────────────────────────────────────────────────
      RouteNames.home               => const HomeDashboardPage(),
      RouteNames.symptomChecker     => const SymptomCheckerPage(),
      RouteNames.history            => const HistoryPage(),
      RouteNames.chatbot            => const ChatbotHomePage(),
      RouteNames.diseasePrediction  => const DiseasePredictionHomePage(),
      RouteNames.emergency          => const EmergencyPage(),
      RouteNames.nearbyHealthcare   => const NearbyHealthcarePage(),
      RouteNames.healthRecords      => const HealthRecordsPage(),
      RouteNames.profile            => const ProfilePage(),
      RouteNames.settings           => const SettingsPage(),
      RouteNames.healthEducation    => const HealthEducationPage(),
      RouteNames.prediction         => PredictionPage(
          prediction: settings.arguments is Prediction
              ? settings.arguments! as Prediction
              : Prediction.empty(),
        ),
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
