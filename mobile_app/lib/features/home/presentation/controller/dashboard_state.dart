// lib/features/home/presentation/controller/dashboard_state.dart
import '../../domain/entities/weather.dart';
import '../../domain/entities/health_score.dart';
import '../../domain/entities/quick_action.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/article.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState {
  final DashboardStatus status;
  final Weather? weather;
  final HealthScore? healthScore;
  final List<QuickAction> quickActions;
  final List<Prediction> recentPredictions;
  final List<Hospital> nearbyHospitals;
  final List<String> healthTips;
  final List<Article> latestArticles;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.weather,
    this.healthScore,
    this.quickActions = const [],
    this.recentPredictions = const [],
    this.nearbyHospitals = const [],
    this.healthTips = const [],
    this.latestArticles = const [],
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    Weather? weather,
    HealthScore? healthScore,
    List<QuickAction>? quickActions,
    List<Prediction>? recentPredictions,
    List<Hospital>? nearbyHospitals,
    List<String>? healthTips,
    List<Article>? latestArticles,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      healthScore: healthScore ?? this.healthScore,
      quickActions: quickActions ?? this.quickActions,
      recentPredictions: recentPredictions ?? this.recentPredictions,
      nearbyHospitals: nearbyHospitals ?? this.nearbyHospitals,
      healthTips: healthTips ?? this.healthTips,
      latestArticles: latestArticles ?? this.latestArticles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}