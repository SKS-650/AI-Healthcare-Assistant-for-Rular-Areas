import '../../domain/entities/symptom.dart';
import '../../domain/entities/symptom_form.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/symptom_repository.dart';
import '../datasources/symptom_dummy_data.dart';

class SymptomRepositoryImpl implements SymptomRepository {
  // In-memory cache to represent local storage tracking for the dummy phase
  SymptomForm? _cachedForm;

  @override
  Future<List<Symptom>> getSymptoms() async {
    // Simulating network delay or database read
    await Future.delayed(const Duration(milliseconds: 400));
    return SymptomDummyData.availableSymptoms;
  }

  @override
  Future<void> saveSymptomForm(SymptomForm form) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cachedForm = form;
  }

  @override
  Future<SymptomForm?> loadSymptomForm() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _cachedForm;
  }

  @override
  Future<PredictionResult> generateDummyResult(SymptomForm form) async {
    // Simulating complex background diagnostics/processing delay
    await Future.delayed(const Duration(seconds: 3));

    // Simple deterministic dummy logic based on form input
    final hasHighSeverity = form.selectedSymptoms.any((s) => s.severity >= 7);
    final includesShortnessOfBreath = form.selectedSymptoms.any((s) => s.symptom.name.toLowerCase().contains('breath'));

    if (hasHighSeverity || includesShortnessOfBreath) {
      return SymptomDummyData.mockResultHighRisk;
    } else {
      return SymptomDummyData.mockResultMildRisk;
    }
  }
}