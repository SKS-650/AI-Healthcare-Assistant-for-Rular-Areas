import '../../domain/entities/prediction_result.dart';

enum DiseasePredictionStatus { initial, loading, success, failure }

/// Severity levels matching the backend (1-4).
enum SymptomSeverity { mild, moderate, severe, critical }

extension SymptomSeverityExt on SymptomSeverity {
  int get value => index + 1; // 1-4
  String get label =>
      name[0].toUpperCase() + name.substring(1); // Mild / Moderate / …
}

class DiseasePredictionState {
  final DiseasePredictionStatus status;

  // ── Symptom list ──────────────────────────────────────────────────────────
  final List<String> symptoms;

  // ── Step 1 – Patient information ──────────────────────────────────────────
  final int age;
  final String gender; // 'male' | 'female' | 'other'
  final double? weight; // kg, optional
  final double? height; // cm, optional

  // ── Step 2 – Duration & severity ─────────────────────────────────────────
  final int durationDays;
  final SymptomSeverity severity;
  final List<String> existingConditions;
  final List<String> medications;
  final List<String> allergies;

  // ── Output ────────────────────────────────────────────────────────────────
  final PredictionResult? predictionResult;
  final List<PredictionResult> history;
  final String? errorMessage;

  const DiseasePredictionState({
    this.status = DiseasePredictionStatus.initial,
    this.symptoms = const [],
    // Patient defaults
    this.age = 25,
    this.gender = 'male',
    this.weight,
    this.height,
    // Symptom details defaults
    this.durationDays = 3,
    this.severity = SymptomSeverity.moderate,
    this.existingConditions = const [],
    this.medications = const [],
    this.allergies = const [],
    // Output
    this.predictionResult,
    this.history = const [],
    this.errorMessage,
  });

  DiseasePredictionState copyWith({
    DiseasePredictionStatus? status,
    List<String>? symptoms,
    int? age,
    String? gender,
    double? weight,
    double? height,
    bool clearWeight = false,
    bool clearHeight = false,
    int? durationDays,
    SymptomSeverity? severity,
    List<String>? existingConditions,
    List<String>? medications,
    List<String>? allergies,
    PredictionResult? predictionResult,
    List<PredictionResult>? history,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return DiseasePredictionState(
      status: status ?? this.status,
      symptoms: symptoms ?? this.symptoms,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: clearWeight ? null : weight ?? this.weight,
      height: clearHeight ? null : height ?? this.height,
      durationDays: durationDays ?? this.durationDays,
      severity: severity ?? this.severity,
      existingConditions: existingConditions ?? this.existingConditions,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      predictionResult:
          clearResult ? null : predictionResult ?? this.predictionResult,
      history: history ?? this.history,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────

  /// Returns null when valid, or an error string to display.
  String? validateStep1() {
    if (age < 1 || age > 120) return 'Age must be between 1 and 120.';
    if (weight != null && (weight! < 1 || weight! > 300)) {
      return 'Weight must be between 1 and 300 kg.';
    }
    if (height != null && (height! < 30 || height! > 250)) {
      return 'Height must be between 30 and 250 cm.';
    }
    return null;
  }

  String? validateStep3() {
    if (symptoms.isEmpty) return 'Add at least one symptom to continue.';
    return null;
  }
}
