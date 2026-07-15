import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/run_assessment.dart';
import 'assessment_state.dart';

class AssessmentController extends StateNotifier<AssessmentState> {
  final RunAssessment _runAssessment;

  AssessmentController({required RunAssessment runAssessment})
      : _runAssessment = runAssessment,
        super(const AssessmentState());

  // ─────────────────────────────────────────────────────────────────────────
  // Step navigation
  // ─────────────────────────────────────────────────────────────────────────

  void nextStep() {
    if (state.currentStep < AssessmentState.totalSteps - 1) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        status: AssessmentStatus.loadingStep,
      );
      // Small artificial delay so the step animation plays
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) state = state.copyWith(status: AssessmentStatus.initial);
      });
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        clearError: true,
      );
    }
  }

  void resetAssessment() {
    state = const AssessmentState();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 0 — Symptoms
  // ─────────────────────────────────────────────────────────────────────────

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void toggleSymptom(String symptom) {
    final current = List<String>.from(state.selectedSymptoms);
    if (current.contains(symptom)) {
      current.remove(symptom);
    } else {
      current.add(symptom);
    }
    state = state.copyWith(selectedSymptoms: current);
  }

  void addCustomSymptom(String symptom) {
    if (symptom.trim().isEmpty) return;
    final current = List<String>.from(state.selectedSymptoms);
    if (!current.contains(symptom.trim())) {
      current.add(symptom.trim());
    }
    state = state.copyWith(selectedSymptoms: current);
  }

  void setSeverityLevel(int level) {
    assert(level >= 1 && level <= 5);
    state = state.copyWith(severityLevel: level);
  }

  void setDurationHours(double hours) {
    state = state.copyWith(durationHours: hours);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 1 — Patient Details
  // ─────────────────────────────────────────────────────────────────────────

  void setAge(int? age) => state = state.copyWith(age: age);
  void setGender(String? gender) => state = state.copyWith(gender: gender);
  void setWeight(double? weight) => state = state.copyWith(weight: weight);
  void setIsPregnant(bool value) => state = state.copyWith(isPregnant: value);

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2 — Medical History
  // ─────────────────────────────────────────────────────────────────────────

  void setCardiacHistory(bool v)      => state = state.copyWith(hasCardiacHistory: v);
  void setDiabetes(bool v)            => state = state.copyWith(hasDiabetes: v);
  void setHypertension(bool v)        => state = state.copyWith(hasHypertension: v);
  void setRespiratoryDisease(bool v)  => state = state.copyWith(hasRespiratoryDisease: v);
  void setImmunocompromised(bool v)   => state = state.copyWith(isImmunocompromised: v);
  void setRecentAccident(bool v)      => state = state.copyWith(recentAccident: v);
  void setRecentSurgery(bool v)       => state = state.copyWith(recentSurgery: v);
  void setRecentTravel(bool v)        => state = state.copyWith(recentTravel: v);
  void setSnakeBite(bool v)           => state = state.copyWith(snakeBite: v);
  void setExposureToPoison(bool v)    => state = state.copyWith(exposureToPoison: v);

  // ─────────────────────────────────────────────────────────────────────────
  // Run Assessment
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> submitAssessment() async {
    if (state.isRunning) return;

    // Validate: need at least one symptom or a description
    if (state.selectedSymptoms.isEmpty && state.description.trim().isEmpty) {
      state = state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: 'Please describe your symptoms or select at least one symptom.',
      );
      return;
    }

    state = state.copyWith(
      status: AssessmentStatus.running,
      clearError: true,
      clearResult: true,
    );

    try {
      final result = await _runAssessment(state.toInput());
      state = state.copyWith(
        status: AssessmentStatus.result,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: 'Assessment failed. Please check your connection and try again.',
      );
    }
  }
}
