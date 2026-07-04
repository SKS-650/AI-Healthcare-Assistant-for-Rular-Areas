import '../../domain/entities/prediction_result.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/disease_prediction_repository.dart';
import '../datasources/disease_prediction_dummy_data.dart';

class DiseasePredictionRepositoryImpl implements DiseasePredictionRepository {
  final List<PredictionResult> _history =
      DiseasePredictionDummyData.initialHistory();

  @override
  Future<PredictionResult> getPredictionResult(List<String> symptoms) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final match = DiseasePredictionDummyData.matchSymptoms(symptoms);
    return DiseasePredictionDummyData.buildResult(
      match.disease,
      match.recommendation,
      match.confidence,
      match.riskLevel,
    );
  }

  @override
  Future<List<PredictionResult>> getPredictionHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_history);
  }

  @override
  Future<Recommendation> getRecommendations(String diseaseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return switch (diseaseId) {
      'migraine' => DiseasePredictionDummyData.migraineRecommendation,
      'gastritis' => DiseasePredictionDummyData.gastritisRecommendation,
      _ => DiseasePredictionDummyData.fluRecommendation,
    };
  }

  @override
  Future<void> savePrediction(PredictionResult result) async {
    _history.insert(0, result);
  }
}
