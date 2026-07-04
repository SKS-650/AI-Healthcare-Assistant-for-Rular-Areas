import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../features/disease_prediction/presentation/pages/disease_prediction_home_page.dart';
import '../features/emergency/presentation/pages/emergency_page.dart';
import '../features/health_education/presentation/pages/health_education_page.dart';
import '../features/health_records/presentation/pages/health_records_page.dart';
import '../features/home/presentation/pages/home_dashboard_page.dart';
import '../features/medical_chatbot/presentation/pages/chatbot_home_page.dart';
import '../features/nearby_healthcare/presentation/pages/nearby_healthcare_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/symptom_checker/domain/entities/prediction.dart';
import '../features/symptom_checker/presentation/pages/history_page.dart';
import '../features/symptom_checker/presentation/pages/prediction_page.dart';
import '../features/symptom_checker/presentation/pages/symptom_checker_page.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _buildPage(settings),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Widget _buildPage(RouteSettings settings) {
    return switch (settings.name) {
      RouteNames.splash => const SplashPage(),
      RouteNames.home => const HomeDashboardPage(),
      RouteNames.symptomChecker => const SymptomCheckerPage(),
      RouteNames.history => const HistoryPage(),
      RouteNames.chatbot => const ChatbotHomePage(),
      RouteNames.diseasePrediction => const DiseasePredictionHomePage(),
      RouteNames.emergency => const EmergencyPage(),
      RouteNames.nearbyHealthcare => const NearbyHealthcarePage(),
      RouteNames.healthRecords => const HealthRecordsPage(),
      RouteNames.profile => const ProfilePage(),
      RouteNames.settings => const SettingsPage(),
      RouteNames.healthEducation => const HealthEducationPage(),
      RouteNames.prediction => PredictionPage(
          prediction: settings.arguments is Prediction
              ? settings.arguments! as Prediction
              : Prediction.empty(),
        ),
      _ => const _NotFoundPage(),
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
