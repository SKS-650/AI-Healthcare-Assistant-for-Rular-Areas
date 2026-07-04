import '../entities/prediction_result.dart';
import '../repositories/symptom_repository.dart';

class LoadHistory {
  const LoadHistory(this.repository);

  final SymptomRepository repository;

  Future<List<PredictionResult>> call() async {
    return const [];
  }
}
