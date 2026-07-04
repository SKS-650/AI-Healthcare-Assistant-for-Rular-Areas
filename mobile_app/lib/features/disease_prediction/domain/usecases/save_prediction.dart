import '../entities/prediction_result.dart';
import '../repositories/disease_prediction_repository.dart';

class SavePrediction {
  final DiseasePredictionRepository repository;

  const SavePrediction(this.repository);

  Future<void> call(PredictionResult result) {
    return repository.savePrediction(result);
  }
}
