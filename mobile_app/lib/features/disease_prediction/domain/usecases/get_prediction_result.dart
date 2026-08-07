import '../entities/prediction_result.dart';
import '../repositories/disease_prediction_repository.dart';

class GetPredictionResult {
  final DiseasePredictionRepository repository;

  const GetPredictionResult(this.repository);

  Future<PredictionResult> call({
    required List<String> symptoms,
    required int age,
    required String gender,
    double? weight,
    double? height,
    int durationDays = 3,
    int severity = 2,
    List<String> existingConditions = const [],
    List<String> medications = const [],
    List<String> allergies = const [],
  }) {
    return repository.getPredictionResult(
      symptoms: symptoms,
      age: age,
      gender: gender,
      weight: weight,
      height: height,
      durationDays: durationDays,
      severity: severity,
      existingConditions: existingConditions,
      medications: medications,
      allergies: allergies,
    );
  }
}
