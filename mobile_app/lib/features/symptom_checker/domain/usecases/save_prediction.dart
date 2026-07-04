import '../entities/prediction_result.dart';
import '../repositories/symptom_repository.dart';

class SavePrediction {
  const SavePrediction(this.repository);

  final SymptomRepository repository;

  Future<void> call(PredictionResult prediction) async {}
}
