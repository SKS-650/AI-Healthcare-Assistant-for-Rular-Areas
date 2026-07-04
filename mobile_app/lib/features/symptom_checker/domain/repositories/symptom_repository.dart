import '../entities/symptom.dart';
import '../entities/symptom_form.dart';
import '../entities/prediction_result.dart';

abstract class SymptomRepository {
  Future<List<Symptom>> getSymptoms();
  Future<void> saveSymptomForm(SymptomForm form);
  Future<SymptomForm?> loadSymptomForm();
  Future<PredictionResult> generateDummyResult(SymptomForm form);
}