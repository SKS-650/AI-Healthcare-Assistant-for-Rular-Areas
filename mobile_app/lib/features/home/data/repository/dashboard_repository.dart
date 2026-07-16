// lib/features/home/data/repository/dashboard_repository.dart
import '../datasource/dashboard_dummy_data.dart';
import '../models/weather_model.dart';
import '../models/health_score_model.dart';
import '../../domain/entities/quick_action.dart';
import '../models/prediction_model.dart';
import '../models/hospital_model.dart';
import '../models/article_model.dart';

class DashboardRepository {
  Future<WeatherModel> getWeather() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return DashboardDummyData.weather;
  }

  Future<HealthScoreModel> getHealthScore() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DashboardDummyData.healthScore;
  }

  Future<List<QuickAction>> getQuickActions() async {
    return DashboardDummyData.quickActions;
  }

  Future<List<PredictionModel>> getRecentPredictions() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return DashboardDummyData.recentPredictions;
  }

  Future<List<HospitalModel>> getNearbyHospitals() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return DashboardDummyData.nearbyHospitals;
  }

  Future<List<String>> getHealthTips() async {
    return DashboardDummyData.healthTips;
  }

  Future<List<ArticleModel>> getLatestArticles() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return DashboardDummyData.latestArticles;
  }
}