import '../entities/symptom_form.dart';
import '../entities/prediction_result.dart';
import '../repositories/symptom_repository.dart';

class GenerateDummyResult {
  final SymptomRepository repository;

  const GenerateDummyResult(this.repository);

  Future<PredictionResult> call(SymptomForm form) async {
    return await repository.generateDummyResult(form);
  }
}