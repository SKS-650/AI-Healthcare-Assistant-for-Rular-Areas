import 'disease.dart';
import 'recommendation.dart';

class PredictionResult {
  final String id;
  final Disease disease;
  final double confidence;
  final String riskLevel;
  final Map<String, double> probabilities;
  final Recommendation recommendation;
  final DateTime createdAt;

  // ── Extra fields surfaced from the real backend ──────────────────────────
  /// Numeric risk score 0–1 (e.g. 0.11 → 11%).
  final double riskScore;
  /// Human-readable risk factors that raised the score.
  final List<String> riskFactors;
  /// Any critical/emergency symptoms detected.
  final List<String> criticalSymptoms;
  /// Whether the backend flagged this as an emergency.
  final bool isEmergency;
  /// Optional emergency alert text from the backend.
  final String? emergencyAlert;
  /// Ordered list of (disease, confidence) pairs from top_diseases.
  final List<MapEntry<String, double>> topDiseases;

  // ── Patient-profile summary (from input_summary) ──────────────────────────
  final double? bmi;
  final String? bmiCategory;
  final String? durationCategory;
  final String? severityLabel;
  final List<String> existingConditions;
  final List<String> medications;
  final List<String> allergies;
  final List<String> augmentationLog;
  final int? augmentedSymptomCount;

  const PredictionResult({
    required this.id,
    required this.disease,
    required this.confidence,
    required this.riskLevel,
    required this.probabilities,
    required this.recommendation,
    required this.createdAt,
    this.riskScore = 0.0,
    this.riskFactors = const [],
    this.criticalSymptoms = const [],
    this.isEmergency = false,
    this.emergencyAlert,
    this.topDiseases = const [],
    this.bmi,
    this.bmiCategory,
    this.durationCategory,
    this.severityLabel,
    this.existingConditions = const [],
    this.medications = const [],
    this.allergies = const [],
    this.augmentationLog = const [],
    this.augmentedSymptomCount,
  });
}
