/// DTOs that map 1-to-1 with the FastAPI symptom-checker request/response.
///
/// Backend schema reference: backend/app/symptom_checker/schemas.py
library;

// ─────────────────────────────────────────────────────────────────────────────
// REQUEST
// ─────────────────────────────────────────────────────────────────────────────

class SymptomCheckApiRequest {
  final List<String> symptoms;
  final int age;
  final String gender;
  final double? weight;
  final double? height;
  final int? duration;
  final int severity;
  final List<String> existingDiseases;
  final List<String> medications;
  final List<String> allergies;
  final bool pregnancyStatus;

  const SymptomCheckApiRequest({
    required this.symptoms,
    required this.age,
    required this.gender,
    this.weight,
    this.height,
    this.duration,
    this.severity = 2,
    this.existingDiseases = const [],
    this.medications = const [],
    this.allergies = const [],
    this.pregnancyStatus = false,
  });

  Map<String, dynamic> toJson() => {
        'symptoms': symptoms,
        'age': age,
        'gender': gender,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (duration != null) 'duration': duration,
        'severity': severity,
        'existing_diseases': existingDiseases,
        'medications': medications,
        'allergies': allergies,
        'pregnancy_status': pregnancyStatus,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSE
// ─────────────────────────────────────────────────────────────────────────────

class SymptomCheckApiResponse {
  final String status;
  final ApiPrediction prediction;
  final ApiRiskAssessment riskAssessment;
  final ApiRecommendation recommendations;
  final ApiInputSummary inputSummary;
  final String? emergencyAlert;

  const SymptomCheckApiResponse({
    required this.status,
    required this.prediction,
    required this.riskAssessment,
    required this.recommendations,
    required this.inputSummary,
    this.emergencyAlert,
  });

  factory SymptomCheckApiResponse.fromJson(Map<String, dynamic> json) =>
      SymptomCheckApiResponse(
        status: json['status'] as String? ?? 'success',
        prediction: ApiPrediction.fromJson(
            json['prediction'] as Map<String, dynamic>),
        riskAssessment: ApiRiskAssessment.fromJson(
            json['risk_assessment'] as Map<String, dynamic>),
        recommendations: ApiRecommendation.fromJson(
            json['recommendations'] as Map<String, dynamic>),
        inputSummary: ApiInputSummary.fromJson(
            json['input_summary'] as Map<String, dynamic>),
        emergencyAlert: json['emergency_alert'] as String?,
      );
}

// ─── Prediction ───────────────────────────────────────────────────────────────

class ApiPrediction {
  final String primaryDisease;
  final double confidence;
  final List<ApiDiseaseConfidence> topDiseases;

  const ApiPrediction({
    required this.primaryDisease,
    required this.confidence,
    required this.topDiseases,
  });

  factory ApiPrediction.fromJson(Map<String, dynamic> json) => ApiPrediction(
        primaryDisease: json['primary_disease'] as String? ?? 'Unknown',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        topDiseases: (json['top_diseases'] as List<dynamic>? ?? [])
            .map((e) =>
                ApiDiseaseConfidence.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ApiDiseaseConfidence {
  final String disease;
  final double confidence;

  const ApiDiseaseConfidence({
    required this.disease,
    required this.confidence,
  });

  factory ApiDiseaseConfidence.fromJson(Map<String, dynamic> json) =>
      ApiDiseaseConfidence(
        disease: json['disease'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      );
}

// ─── Risk Assessment ─────────────────────────────────────────────────────────

class ApiRiskAssessment {
  final String riskLevel;
  final double riskScore;
  final bool isEmergency;
  final List<String> criticalSymptoms;
  final List<String> riskFactors;
  final Map<String, dynamic>? scoreBreakdown;

  const ApiRiskAssessment({
    required this.riskLevel,
    required this.riskScore,
    required this.isEmergency,
    required this.criticalSymptoms,
    required this.riskFactors,
    this.scoreBreakdown,
  });

  factory ApiRiskAssessment.fromJson(Map<String, dynamic> json) =>
      ApiRiskAssessment(
        riskLevel: json['risk_level'] as String? ?? 'low',
        riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0.0,
        isEmergency: json['is_emergency'] as bool? ?? false,
        criticalSymptoms: List<String>.from(
            json['critical_symptoms'] as List<dynamic>? ?? []),
        riskFactors: List<String>.from(
            json['risk_factors'] as List<dynamic>? ?? []),
        scoreBreakdown: json['score_breakdown'] as Map<String, dynamic>?,
      );
}

// ─── Recommendations ─────────────────────────────────────────────────────────

class ApiRecommendation {
  final String riskLevel;
  final String primaryAction;
  final String department;
  final List<String> actions;
  final List<String> careAdvice;
  final String urgency;
  final bool emergencyContact;

  const ApiRecommendation({
    required this.riskLevel,
    required this.primaryAction,
    required this.department,
    required this.actions,
    required this.careAdvice,
    required this.urgency,
    required this.emergencyContact,
  });

  factory ApiRecommendation.fromJson(Map<String, dynamic> json) =>
      ApiRecommendation(
        riskLevel: json['risk_level'] as String? ?? 'low',
        primaryAction: json['primary_action'] as String? ?? '',
        department: json['department'] as String? ?? 'General',
        actions:
            List<String>.from(json['actions'] as List<dynamic>? ?? []),
        careAdvice:
            List<String>.from(json['care_advice'] as List<dynamic>? ?? []),
        urgency: json['urgency'] as String? ?? 'routine',
        emergencyContact: json['emergency_contact'] as bool? ?? false,
      );
}

// ─── Input Summary ────────────────────────────────────────────────────────────

class ApiInputSummary {
  final int symptomCount;
  final List<String> symptoms;
  final int age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final double? bmi;
  final String? bmiCategory;
  final int? durationDays;
  final String? durationCategory;
  final int severity;
  final String? severityLabel;
  final List<String> existingConditions;
  final List<String> medications;
  final List<String> allergies;
  final bool? pregnancyStatus;
  final int? augmentedSymptomCount;
  final List<String>? augmentedSymptoms;
  final List<String>? augmentationLog;

  const ApiInputSummary({
    required this.symptomCount,
    required this.symptoms,
    required this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.bmi,
    this.bmiCategory,
    this.durationDays,
    this.durationCategory,
    required this.severity,
    this.severityLabel,
    this.existingConditions = const [],
    this.medications = const [],
    this.allergies = const [],
    this.pregnancyStatus,
    this.augmentedSymptomCount,
    this.augmentedSymptoms,
    this.augmentationLog,
  });

  factory ApiInputSummary.fromJson(Map<String, dynamic> json) =>
      ApiInputSummary(
        symptomCount: json['symptom_count'] as int? ?? 0,
        symptoms:
            List<String>.from(json['symptoms'] as List<dynamic>? ?? []),
        age: json['age'] as int? ?? 0,
        gender: json['gender'] as String?,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        bmi: (json['bmi'] as num?)?.toDouble(),
        bmiCategory: json['bmi_category'] as String?,
        durationDays: json['duration_days'] as int?,
        durationCategory: json['duration_category'] as String?,
        severity: json['severity'] as int? ?? 1,
        severityLabel: json['severity_label'] as String?,
        existingConditions: List<String>.from(
            json['existing_conditions'] as List<dynamic>? ?? []),
        medications: List<String>.from(
            json['medications'] as List<dynamic>? ?? []),
        allergies: List<String>.from(
            json['allergies'] as List<dynamic>? ?? []),
        pregnancyStatus: json['pregnancy_status'] as bool?,
        augmentedSymptomCount: json['augmented_symptom_count'] as int?,
        augmentedSymptoms: json['augmented_symptoms'] != null
            ? List<String>.from(
                json['augmented_symptoms'] as List<dynamic>)
            : null,
        augmentationLog: json['augmentation_log'] != null
            ? List<String>.from(json['augmentation_log'] as List<dynamic>)
            : null,
      );
}
