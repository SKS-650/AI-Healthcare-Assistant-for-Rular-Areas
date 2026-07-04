import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lifestyle.dart';
import '../../domain/entities/medical_history.dart';
import '../../domain/entities/selected_symptom.dart';
import '../../domain/entities/symptom.dart';
import '../../domain/entities/symptom_form.dart';
import '../../domain/usecases/generate_dummy_result.dart';
import '../../domain/usecases/get_symptoms.dart';
import 'symptom_state.dart';

class SymptomController extends StateNotifier<SymptomState> {
  final GetSymptoms _getSymptoms;
  final GenerateDummyResult _generateDummyResult;

  SymptomController({
    required GetSymptoms getSymptoms,
    required GenerateDummyResult generateDummyResult,
  })  : _getSymptoms = getSymptoms,
        _generateDummyResult = generateDummyResult,
        super(const SymptomState()) {
    loadAvailableSymptoms();
  }

  Future<void> loadAvailableSymptoms() async {
    state = state.copyWith(status: SymptomStatus.loading);
    try {
      final symptoms = await _getSymptoms();
      state = state.copyWith(
        status: SymptomStatus.success,
        availableSymptoms: symptoms,
      );
    } catch (e) {
      state = state.copyWith(
        status: SymptomStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void toggleSymptomSelection(Symptom symptom) {
    final contains = state.selectedSymptoms.any((s) => s.symptom.id == symptom.id);
    List<SelectedSymptom> updated;
    if (contains) {
      updated = state.selectedSymptoms.where((s) => s.symptom.id != symptom.id).toList();
    } else {
      updated = [
        ...state.selectedSymptoms,
        SelectedSymptom(symptom: symptom, severity: 5.0, durationInDays: 2)
      ];
    }
    state = state.copyWith(selectedSymptoms: updated);
  }

  void updateSymptomSeverity(String symptomId, double severity) {
    final updated = state.selectedSymptoms.map((s) {
      if (s.symptom.id == symptomId) {
        return SelectedSymptom(symptom: s.symptom, severity: severity, durationInDays: s.durationInDays);
      }
      return s;
    }).toList();
    state = state.copyWith(selectedSymptoms: updated);
  }

  void updateSymptomDuration(String symptomId, int durationInDays) {
    final updated = state.selectedSymptoms.map((s) {
      if (s.symptom.id == symptomId) {
        return SelectedSymptom(symptom: s.symptom, severity: s.severity, durationInDays: durationInDays);
      }
      return s;
    }).toList();
    state = state.copyWith(selectedSymptoms: updated);
  }

  void updatePersonalInfo({int? age, String? gender}) {
    state = state.copyWith(
      age: age ?? state.age,
      gender: gender ?? state.gender,
    );
  }

  void updateMedicalHistory({
    List<String>? conditions,
    List<String>? allergies,
    List<String>? medications,
  }) {
    state = state.copyWith(
      chronicConditions: conditions ?? state.chronicConditions,
      allergies: allergies ?? state.allergies,
      currentMedications: medications ?? state.currentMedications,
    );
  }

  void updateLifestyle({
    String? smoking,
    String? alcohol,
    String? exercise,
    int? sleep,
  }) {
    state = state.copyWith(
      smokingHabit: smoking ?? state.smokingHabit,
      alcoholConsumption: alcohol ?? state.alcoholConsumption,
      exerciseFrequency: exercise ?? state.exerciseFrequency,
      averageSleepHours: sleep ?? state.averageSleepHours,
    );
  }

  void nextStep() {
    if (state.currentStep < 6) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  Future<void> runDiagnosticAnalysis() async {
    state = state.copyWith(status: SymptomStatus.loading);
    
    final form = SymptomForm(
      selectedSymptoms: state.selectedSymptoms,
      age: state.age,
      gender: state.gender,
      medicalHistory: MedicalHistory(
        chronicConditions: state.chronicConditions,
        allergies: state.allergies,
        currentMedications: state.currentMedications,
      ),
      lifestyle: Lifestyle(
        smokingHabit: state.smokingHabit,
        alcoholConsumption: state.alcoholConsumption,
        exerciseFrequency: state.exerciseFrequency,
        averageSleepHours: state.averageSleepHours,
      ),
    );

    try {
      final res = await _generateDummyResult(form);
      state = state.copyWith(
        status: SymptomStatus.success,
        predictionResult: res,
      );
    } catch (e) {
      state = state.copyWith(
        status: SymptomStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void resetForm() {
    state = const SymptomState();
    loadAvailableSymptoms();
  }
}