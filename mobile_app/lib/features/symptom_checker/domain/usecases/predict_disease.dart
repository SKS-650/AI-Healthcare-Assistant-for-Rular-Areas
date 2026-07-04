import '../entities/prediction_result.dart';
import '../entities/symptom.dart';
import '../repositories/symptom_repository.dart';

class PredictDisease {
  const PredictDisease(this.repository);

  final SymptomRepository repository;

  Future<PredictionResult> call({
    required List<Symptom> symptoms,
    required double severity,
  }) async {
    return PredictionResult(
      conditionName: 'Analysis pending',
      confidenceScore: 0.0,
      riskLevel: 'Low',
      description: 'Prediction flow is handled by the symptom checker controller.',
      recommendations: const [],
    );
  }
}
