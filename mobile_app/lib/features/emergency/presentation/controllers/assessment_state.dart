import '../../domain/entities/emergency_assessment.dart';

enum AssessmentStatus {
  initial,
  loadingStep,  // multi-step form is transitioning
  running,      // AI pipeline call in progress
  result,       // result ready
  error,
}

/// Holds the entire multi-step assessment form state + AI result.
class AssessmentState {
  // ── Form navigation ───────────────────────────────────────────────────────
  final AssessmentStatus status;
  final int currentStep;         // 0-based; 0 = symptoms, 1 = details, 2 = history
  static const int totalSteps = 3;

  // ── Step 0 — Symptoms ─────────────────────────────────────────────────────
  final String description;
  final List<String> selectedSymptoms;
  final int severityLevel;       // 1-5
  final double durationHours;

  // ── Step 1 — Patient Details ──────────────────────────────────────────────
  final int? age;
  final String? gender;
  final double? weight;
  final bool isPregnant;

  // ── Step 2 — Medical History + Context ────────────────────────────────────
  final bool hasCardiacHistory;
  final bool hasDiabetes;
  final bool hasHypertension;
  final bool hasRespiratoryDisease;
  final bool isImmunocompromised;
  final bool recentAccident;
  final bool recentSurgery;
  final bool recentTravel;
  final bool snakeBite;
  final bool exposureToPoison;

  // ── Result ────────────────────────────────────────────────────────────────
  final EmergencyAssessment? result;
  final String? errorMessage;

  const AssessmentState({
    this.status      = AssessmentStatus.initial,
    this.currentStep = 0,
    this.description = '',
    this.selectedSymptoms = const [],
    this.severityLevel    = 1,
    this.durationHours    = 0.0,
    this.age,
    this.gender,
    this.weight,
    this.isPregnant = false,
    this.hasCardiacHistory      = false,
    this.hasDiabetes            = false,
    this.hasHypertension        = false,
    this.hasRespiratoryDisease  = false,
    this.isImmunocompromised    = false,
    this.recentAccident         = false,
    this.recentSurgery          = false,
    this.recentTravel           = false,
    this.snakeBite              = false,
    this.exposureToPoison       = false,
    this.result,
    this.errorMessage,
  });

  bool get isRunning   => status == AssessmentStatus.running;
  bool get hasResult   => status == AssessmentStatus.result && result != null;
  bool get isLastStep  => currentStep == totalSteps - 1;
  bool get isFirstStep => currentStep == 0;

  AssessmentState copyWith({
    AssessmentStatus? status,
    int? currentStep,
    String? description,
    List<String>? selectedSymptoms,
    int? severityLevel,
    double? durationHours,
    int? age,
    String? gender,
    double? weight,
    bool? isPregnant,
    bool? hasCardiacHistory,
    bool? hasDiabetes,
    bool? hasHypertension,
    bool? hasRespiratoryDisease,
    bool? isImmunocompromised,
    bool? recentAccident,
    bool? recentSurgery,
    bool? recentTravel,
    bool? snakeBite,
    bool? exposureToPoison,
    EmergencyAssessment? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return AssessmentState(
      status:       status       ?? this.status,
      currentStep:  currentStep  ?? this.currentStep,
      description:  description  ?? this.description,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      severityLevel:    severityLevel    ?? this.severityLevel,
      durationHours:    durationHours    ?? this.durationHours,
      age:        age        ?? this.age,
      gender:     gender     ?? this.gender,
      weight:     weight     ?? this.weight,
      isPregnant: isPregnant ?? this.isPregnant,
      hasCardiacHistory:     hasCardiacHistory     ?? this.hasCardiacHistory,
      hasDiabetes:           hasDiabetes           ?? this.hasDiabetes,
      hasHypertension:       hasHypertension       ?? this.hasHypertension,
      hasRespiratoryDisease: hasRespiratoryDisease ?? this.hasRespiratoryDisease,
      isImmunocompromised:   isImmunocompromised   ?? this.isImmunocompromised,
      recentAccident:    recentAccident    ?? this.recentAccident,
      recentSurgery:     recentSurgery     ?? this.recentSurgery,
      recentTravel:      recentTravel      ?? this.recentTravel,
      snakeBite:         snakeBite         ?? this.snakeBite,
      exposureToPoison:  exposureToPoison  ?? this.exposureToPoison,
      result:       clearResult ? null  : (result ?? this.result),
      errorMessage: clearError  ? null  : (errorMessage ?? this.errorMessage),
    );
  }

  /// Convert current state to the domain input object
  AssessmentInput toInput() => AssessmentInput(
    description:           description,
    age:                   age,
    gender:                gender,
    weight:                weight,
    symptoms:              selectedSymptoms,
    severityLevel:         severityLevel,
    durationHours:         durationHours,
    hasCardiacHistory:     hasCardiacHistory,
    hasDiabetes:           hasDiabetes,
    hasHypertension:       hasHypertension,
    hasRespiratoryDisease: hasRespiratoryDisease,
    isImmunocompromised:   isImmunocompromised,
    isPregnant:            isPregnant,
    recentAccident:        recentAccident,
    recentSurgery:         recentSurgery,
    recentTravel:          recentTravel,
    snakeBite:             snakeBite,
    exposureToPoison:      exposureToPoison,
  );
}
