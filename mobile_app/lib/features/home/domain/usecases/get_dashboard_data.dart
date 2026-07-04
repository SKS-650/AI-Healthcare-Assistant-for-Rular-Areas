// lib/features/home/domain/usecases/get_dashboard_data.dart
import '../../data/repository/dashboard_repository.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/health_score_model.dart';
import '../../data/models/prediction_model.dart';
import '../../data/models/hospital_model.dart';
import '../../data/models/article_model.dart';
import '../entities/quick_action.dart';

class GetDashboardData {
  final DashboardRepository _repository;

  const GetDashboardData(this._repository);

  Future<WeatherModel> fetchWeather() => _repository.getWeather();
  Future<HealthScoreModel> fetchHealthScore() => _repository.getHealthScore();
  Future<List<QuickAction>> fetchQuickActions() => _repository.getQuickActions();
  Future<List<PredictionModel>> fetchRecentPredictions() => _repository.getRecentPredictions();
  Future<List<HospitalModel>> fetchNearbyHospitals() => _repository.getNearbyHospitals();
  Future<List<String>> fetchHealthTips() => _repository.getHealthTips();
  Future<List<ArticleModel>> fetchLatestArticles() => _repository.getLatestArticles();
}