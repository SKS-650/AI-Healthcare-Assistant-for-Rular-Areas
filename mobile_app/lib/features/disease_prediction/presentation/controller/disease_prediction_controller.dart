import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/prediction_result.dart';
import '../../domain/usecases/get_prediction_history.dart';
import '../../domain/usecases/get_prediction_result.dart';
import '../../domain/usecases/save_prediction.dart';
import 'disease_prediction_state.dart';

class DiseasePredictionController
    extends StateNotifier<DiseasePredictionState> {
  final GetPredictionResult getPredictionResult;
  final SavePrediction savePrediction;
  final GetPredictionHistory getPredictionHistory;

  DiseasePredictionController({
    required this.getPredictionResult,
    required this.savePrediction,
    required this.getPredictionHistory,
  }) : super(const DiseasePredictionState()) {
    loadHistory();
  }

  // ── Step 1: Patient information ───────────────────────────────────────────

  void setAge(int age) {
    state = state.copyWith(age: age, clearError: true);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender, clearError: true);
  }

  void setWeight(double? weight) {
    if (weight == null) {
      state = state.copyWith(clearWeight: true, clearError: true);
    } else {
      state = state.copyWith(weight: weight, clearError: true);
    }
  }

  void setHeight(double? height) {
    if (height == null) {
      state = state.copyWith(clearHeight: true, clearError: true);
    } else {
      state = state.copyWith(height: height, clearError: true);
    }
  }

  // ── Step 2: Duration & severity ───────────────────────────────────────────

  void setDurationDays(int days) {
    state = state.copyWith(durationDays: days, clearError: true);
  }

  void setSeverity(SymptomSeverity severity) {
    state = state.copyWith(severity: severity, clearError: true);
  }

  void addCondition(String condition) {
    final v = condition.trim();
    if (v.isEmpty || state.existingConditions.contains(v)) return;
    state = state.copyWith(
      existingConditions: [...state.existingConditions, v],
      clearError: true,
    );
  }

  void removeCondition(String condition) {
    state = state.copyWith(
      existingConditions:
          state.existingConditions.where((c) => c != condition).toList(),
    );
  }

  void addMedication(String medication) {
    final v = medication.trim();
    if (v.isEmpty || state.medications.contains(v)) return;
    state = state.copyWith(
      medications: [...state.medications, v],
      clearError: true,
    );
  }

  void removeMedication(String medication) {
    state = state.copyWith(
      medications:
          state.medications.where((m) => m != medication).toList(),
    );
  }

  void addAllergy(String allergy) {
    final v = allergy.trim();
    if (v.isEmpty || state.allergies.contains(v)) return;
    state = state.copyWith(
      allergies: [...state.allergies, v],
      clearError: true,
    );
  }

  void removeAllergy(String allergy) {
    state = state.copyWith(
      allergies: state.allergies.where((a) => a != allergy).toList(),
    );
  }

  // ── Step 3: Symptoms ──────────────────────────────────────────────────────

  void addSymptom(String symptom) {
    final value = symptom.trim();
    if (value.isEmpty || state.symptoms.contains(value)) return;
    state = state.copyWith(
      symptoms: [...state.symptoms, value],
      clearError: true,
    );
  }

  void removeSymptom(String symptom) {
    state = state.copyWith(
      symptoms: state.symptoms.where((item) => item != symptom).toList(),
    );
  }

  // ── Validation helpers (called by UI before navigating) ───────────────────

  /// Returns null if step 1 is valid, otherwise an error message.
  String? validateStep1() => state.validateStep1();

  /// Returns null if the symptom list is not empty, otherwise an error message.
  String? validateStep3() => state.validateStep3();

  // ── Prediction ────────────────────────────────────────────────────────────

  Future<void> predict() async {
    final err = state.validateStep3();
    if (err != null) {
      state = state.copyWith(
        status: DiseasePredictionStatus.failure,
        errorMessage: err,
      );
      return;
    }

    state = state.copyWith(
      status: DiseasePredictionStatus.loading,
      clearError: true,
    );

    try {
      final result = await getPredictionResult(
        symptoms: state.symptoms,
        age: state.age,
        gender: state.gender,
        weight: state.weight,
        height: state.height,
        durationDays: state.durationDays,
        severity: state.severity.value,
        existingConditions: state.existingConditions,
        medications: state.medications,
        allergies: state.allergies,
      );
      await savePrediction(result);
      final history = await getPredictionHistory();
      state = state.copyWith(
        status: DiseasePredictionStatus.success,
        predictionResult: result,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(
        status: DiseasePredictionStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadHistory() async {
    try {
      final history = await getPredictionHistory();
      state = state.copyWith(history: history);
    } catch (_) {
      // History load failure is non-critical; do not surface an error.
    }
  }

  void selectResult(PredictionResult result) {
    state = state.copyWith(
      status: DiseasePredictionStatus.success,
      predictionResult: result,
    );
  }

  void reset() {
    state = DiseasePredictionState(history: state.history);
  }
}
