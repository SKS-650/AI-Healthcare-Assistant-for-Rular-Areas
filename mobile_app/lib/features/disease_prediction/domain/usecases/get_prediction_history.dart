import '../entities/prediction_result.dart';
import '../repositories/disease_prediction_repository.dart';

class GetPredictionHistory {
  final DiseasePredictionRepository repository;

  const GetPredictionHistory(this.repository);

  Future<List<PredictionResult>> call() {
    return repository.getPredictionHistory();
  }
}
