/// Model for disease prediction
class DiseasePrediction {
  final String disease;
  final double confidence;

  DiseasePrediction({
    required this.disease,
    required this.confidence,
  });

  factory DiseasePrediction.fromJson(Map<String, dynamic> json) {
    return DiseasePrediction(
      disease: json['disease'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

/// Model for risk assessment
class RiskAssessment {
  final String riskLevel;
  final double riskScore;
  final bool isEmergency;
  final List<String> criticalSymptoms;
  final List<String> riskFactors;

  RiskAssessment({
    required this.riskLevel,
    required this.riskScore,
    required this.isEmergency,
    required this.criticalSymptoms,
    required this.riskFactors,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      riskLevel: json['risk_level'] ?? 'medium',
      riskScore: (json['risk_score'] ?? 0.0).toDouble(),
      isEmergency: json['is_emergency'] ?? false,
      criticalSymptoms: List<String>.from(json['critical_symptoms'] ?? []),
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
    );
  }

  String get riskLevelLabel {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return 'Low Risk';
      case 'medium':
        return 'Medium Risk';
      case 'high':
        return 'High Risk';
      case 'critical':
        return 'CRITICAL - Emergency';
      default:
        return 'Unknown';
    }
  }
}

/// Model for recommendations
class Recommendations {
  final String riskLevel;
  final String primaryAction;
  final String department;
  final String departmentCode;
  final List<String> actions;
  final List<String> careAdvice;
  final Map<String, dynamic> followUp;
  final String urgency;
  final bool emergencyContact;

  Recommendations({
    required this.riskLevel,
    required this.primaryAction,
    required this.department,
    required this.departmentCode,
    required this.actions,
    required this.careAdvice,
    required this.followUp,
    required this.urgency,
    required this.emergencyContact,
  });

  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      riskLevel: json['risk_level'] ?? 'medium',
      primaryAction: json['primary_action'] ?? '',
      department: json['department'] ?? '',
      departmentCode: json['department_code'] ?? '',
      actions: List<String>.from(json['actions'] ?? []),
      careAdvice: List<String>.from(json['care_advice'] ?? []),
      followUp: Map<String, dynamic>.from(json['follow_up'] ?? {}),
      urgency: json['urgency'] ?? '',
      emergencyContact: json['emergency_contact'] ?? false,
    );
  }
}

/// Main response model
class SymptomCheckResponse {
  final String status;
  final Map<String, dynamic> prediction;
  final RiskAssessment riskAssessment;
  final Recommendations recommendations;
  final Map<String, dynamic> inputSummary;
  final Map<String, dynamic> metadata;
  final String? emergencyAlert;

  SymptomCheckResponse({
    required this.status,
    required this.prediction,
    required this.riskAssessment,
    required this.recommendations,
    required this.inputSummary,
    required this.metadata,
    this.emergencyAlert,
  });

  factory SymptomCheckResponse.fromJson(Map<String, dynamic> json) {
    return SymptomCheckResponse(
      status: json['status'] ?? 'error',
      prediction: Map<String, dynamic>.from(json['prediction'] ?? {}),
      riskAssessment: RiskAssessment.fromJson(json['risk_assessment'] ?? {}),
      recommendations: Recommendations.fromJson(json['recommendations'] ?? {}),
      inputSummary: Map<String, dynamic>.from(json['input_summary'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      emergencyAlert: json['emergency_alert'],
    );
  }

  String get primaryDisease => prediction['primary_disease'] ?? 'Unknown';

  double get primaryConfidence =>
      (prediction['confidence'] ?? 0.0).toDouble();

  List<DiseasePrediction> get topDiseases {
    final List topDiseasesJson = prediction['top_diseases'] ?? [];
    return topDiseasesJson
        .map((d) => DiseasePrediction.fromJson(d as Map<String, dynamic>))
        .toList();
  }
}
