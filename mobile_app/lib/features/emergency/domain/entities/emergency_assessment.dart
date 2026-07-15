import 'first_aid_guide.dart';
import 'hospital.dart';
import 'risk_level.dart';

/// Full AI assessment result returned from POST /api/v1/emergency/assessment
class EmergencyAssessment {
  final String id;
  final bool isEmergency;
  final int riskScore;            // 0–100
  final RiskLevel riskLevel;
  final String riskLevelColor;    // hex
  final String riskLevelEmoji;
  final String possibleEmergency;
  final String? emergencyType;
  final String recommendedDept;
  final String warningMessage;
  final bool sosRequired;
  final FirstAidGuide? firstAid;
  final List<Hospital> hospitalRecommendations;
  final List<String> matchedKeywords;
  final double mlConfidence;
  final DateTime createdAt;

  const EmergencyAssessment({
    required this.id,
    required this.isEmergency,
    required this.riskScore,
    required this.riskLevel,
    required this.riskLevelColor,
    required this.riskLevelEmoji,
    required this.possibleEmergency,
    this.emergencyType,
    required this.recommendedDept,
    required this.warningMessage,
    required this.sosRequired,
    this.firstAid,
    required this.hospitalRecommendations,
    required this.matchedKeywords,
    required this.mlConfidence,
    required this.createdAt,
  });
}

/// Structured input sent by the Flutter app to request an assessment.
class AssessmentInput {
  // ── Free text ─────────────────────────────────────────────────────────────
  final String description;

  // ── Demographics ──────────────────────────────────────────────────────────
  final int? age;
  final String? gender;   // 'male' | 'female' | 'other'
  final double? weight;

  // ── Symptoms ──────────────────────────────────────────────────────────────
  final List<String> symptoms;
  final int severityLevel;   // 1–5
  final double durationHours;

  // ── Medical history ───────────────────────────────────────────────────────
  final bool hasCardiacHistory;
  final bool hasDiabetes;
  final bool hasHypertension;
  final bool hasRespiratoryDisease;
  final bool isImmunocompromised;
  final bool isPregnant;

  // ── Context flags ─────────────────────────────────────────────────────────
  final bool recentAccident;
  final bool recentSurgery;
  final bool recentTravel;
  final bool snakeBite;
  final bool exposureToPoison;

  const AssessmentInput({
    this.description = '',
    this.age,
    this.gender,
    this.weight,
    this.symptoms = const [],
    this.severityLevel = 1,
    this.durationHours = 0.0,
    this.hasCardiacHistory = false,
    this.hasDiabetes = false,
    this.hasHypertension = false,
    this.hasRespiratoryDisease = false,
    this.isImmunocompromised = false,
    this.isPregnant = false,
    this.recentAccident = false,
    this.recentSurgery = false,
    this.recentTravel = false,
    this.snakeBite = false,
    this.exposureToPoison = false,
  });

  AssessmentInput copyWith({
    String? description,
    int? age,
    String? gender,
    double? weight,
    List<String>? symptoms,
    int? severityLevel,
    double? durationHours,
    bool? hasCardiacHistory,
    bool? hasDiabetes,
    bool? hasHypertension,
    bool? hasRespiratoryDisease,
    bool? isImmunocompromised,
    bool? isPregnant,
    bool? recentAccident,
    bool? recentSurgery,
    bool? recentTravel,
    bool? snakeBite,
    bool? exposureToPoison,
  }) {
    return AssessmentInput(
      description: description ?? this.description,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      symptoms: symptoms ?? this.symptoms,
      severityLevel: severityLevel ?? this.severityLevel,
      durationHours: durationHours ?? this.durationHours,
      hasCardiacHistory: hasCardiacHistory ?? this.hasCardiacHistory,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasHypertension: hasHypertension ?? this.hasHypertension,
      hasRespiratoryDisease: hasRespiratoryDisease ?? this.hasRespiratoryDisease,
      isImmunocompromised: isImmunocompromised ?? this.isImmunocompromised,
      isPregnant: isPregnant ?? this.isPregnant,
      recentAccident: recentAccident ?? this.recentAccident,
      recentSurgery: recentSurgery ?? this.recentSurgery,
      recentTravel: recentTravel ?? this.recentTravel,
      snakeBite: snakeBite ?? this.snakeBite,
      exposureToPoison: exposureToPoison ?? this.exposureToPoison,
    );
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    if (age != null) 'age': age,
    if (gender != null) 'gender': gender,
    if (weight != null) 'weight': weight,
    'symptoms': symptoms,
    'severity_level': severityLevel,
    'duration_hours': durationHours,
    'has_cardiac_history': hasCardiacHistory,
    'has_diabetes': hasDiabetes,
    'has_hypertension': hasHypertension,
    'has_respiratory_disease': hasRespiratoryDisease,
    'is_immunocompromised': isImmunocompromised,
    'is_pregnant': isPregnant,
    'recent_accident': recentAccident,
    'recent_surgery': recentSurgery,
    'recent_travel': recentTravel,
    'snake_bite': snakeBite,
    'exposure_to_poison': exposureToPoison,
    'language': 'en',
  };
}
