import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardController extends StateNotifier<DashboardState> {
  final DashboardRepository repository;

  DashboardController(this.repository) : super(const DashboardState()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    if (state.status == DashboardStatus.loading) return;

    state = state.copyWith(status: DashboardStatus.loading, errorMessage: null);

    try {
      final weather = await repository.getWeather();
      final healthScore = await repository.getHealthScore();
      final quickActions = await repository.getQuickActions();
      final recentPredictions = await repository.getRecentPredictions();
      final healthTips = await repository.getHealthTips();
      final latestArticles = await repository.getLatestArticles();

      state = state.copyWith(
        status: DashboardStatus.loaded,
        weather: weather,
        healthScore: healthScore,
        quickActions: quickActions,
        recentPredictions: recentPredictions,
        healthTips: healthTips,
        latestArticles: latestArticles,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: DashboardStatus.error,
        errorMessage: error.toString(),
      );
    }
  }
}