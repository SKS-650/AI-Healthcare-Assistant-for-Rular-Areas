import '../entities/prediction_result.dart';
import '../repositories/disease_prediction_repository.dart';

class GetPredictionResult {
  final DiseasePredictionRepository repository;

  const GetPredictionResult(this.repository);

  Future<PredictionResult> call(List<String> symptoms) {
    return repository.getPredictionResult(symptoms);
  }
}
