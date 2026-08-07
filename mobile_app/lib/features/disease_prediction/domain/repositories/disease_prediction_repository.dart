import '../entities/prediction_result.dart';
import '../entities/recommendation.dart';

abstract class DiseasePredictionRepository {
  Future<PredictionResult> getPredictionResult({
    required List<String> symptoms,
    required int age,
    required String gender,
    double? weight,
    double? height,
    int durationDays,
    int severity,
    List<String> existingConditions,
    List<String> medications,
    List<String> allergies,
  });

  Future<void> savePrediction(PredictionResult result);
  Future<List<PredictionResult>> getPredictionHistory();
  Future<Recommendation> getRecommendations(String diseaseId);
}
