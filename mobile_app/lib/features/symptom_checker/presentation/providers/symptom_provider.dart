import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/symptom_repository_impl.dart';
import '../../domain/usecases/generate_dummy_result.dart';
import '../../domain/usecases/get_symptoms.dart';
import '../controllers/symptom_controller.dart';
import '../controllers/symptom_state.dart';

final symptomRepositoryProvider = Provider((ref) => SymptomRepositoryImpl());

final getSymptomsUseCaseProvider = Provider((ref) {
  final repo = ref.watch(symptomRepositoryProvider);
  return GetSymptoms(repo);
});

final generateDummyResultUseCaseProvider = Provider((ref) {
  final repo = ref.watch(symptomRepositoryProvider);
  return GenerateDummyResult(repo);
});

final symptomControllerProvider = StateNotifierProvider<SymptomController, SymptomState>((ref) {
  final getSymptoms = ref.watch(getSymptomsUseCaseProvider);
  final generateResult = ref.watch(generateDummyResultUseCaseProvider);
  return SymptomController(
    getSymptoms: getSymptoms,
    generateDummyResult: generateResult,
  );
});