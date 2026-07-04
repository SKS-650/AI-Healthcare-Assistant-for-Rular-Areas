import '../entities/prediction_result.dart';
import '../entities/recommendation.dart';

abstract class DiseasePredictionRepository {
  Future<PredictionResult> getPredictionResult(List<String> symptoms);
  Future<void> savePrediction(PredictionResult result);
  Future<List<PredictionResult>> getPredictionHistory();
  Future<Recommendation> getRecommendations(String diseaseId);
}
