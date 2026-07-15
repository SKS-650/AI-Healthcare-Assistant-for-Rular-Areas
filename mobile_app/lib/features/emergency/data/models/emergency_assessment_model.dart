import '../../domain/entities/emergency_assessment.dart';
import '../../domain/entities/first_aid_guide.dart';
import '../../domain/entities/risk_level.dart';
import 'hospital_model.dart';

class FirstAidGuideModel extends FirstAidGuide {
  const FirstAidGuideModel({
    required super.title,
    required super.emoji,
    required super.steps,
    required super.doNotSteps,
    required super.callToAction,
  });

  factory FirstAidGuideModel.fromJson(Map<String, dynamic> json) {
    return FirstAidGuideModel(
      title: json['title'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🚨',
      steps: List<String>.from(json['steps'] as List? ?? []),
      doNotSteps: List<String>.from(json['do_not_steps'] as List? ?? []),
      callToAction: json['call_to_action'] as String? ?? 'Call 102',
    );
  }
}

class EmergencyAssessmentModel extends EmergencyAssessment {
  const EmergencyAssessmentModel({
    required super.id,
    required super.isEmergency,
    required super.riskScore,
    required super.riskLevel,
    required super.riskLevelColor,
    required super.riskLevelEmoji,
    required super.possibleEmergency,
    super.emergencyType,
    required super.recommendedDept,
    required super.warningMessage,
    required super.sosRequired,
    super.firstAid,
    required super.hospitalRecommendations,
    required super.matchedKeywords,
    required super.mlConfidence,
    required super.createdAt,
  });

  factory EmergencyAssessmentModel.fromJson(Map<String, dynamic> json) {
    // Parse first aid
    FirstAidGuide? firstAid;
    if (json['first_aid'] != null) {
      firstAid = FirstAidGuideModel.fromJson(
        json['first_aid'] as Map<String, dynamic>,
      );
    }

    // Parse hospital recommendations
    final hospitals = (json['hospital_recommendation'] as List? ?? [])
        .map((h) => HospitalModel.fromJson(h as Map<String, dynamic>))
        .toList();

    return EmergencyAssessmentModel(
      id: json['id'] as String,
      isEmergency: json['is_emergency'] as bool? ?? false,
      riskScore: json['risk_score'] as int? ?? 0,
      riskLevel: RiskLevel.fromString(json['risk_level'] as String? ?? 'LOW'),
      riskLevelColor: json['risk_level_color'] as String? ?? '#2ECC8B',
      riskLevelEmoji: json['risk_level_emoji'] as String? ?? '🟢',
      possibleEmergency: json['possible_emergency'] as String? ?? 'No emergency',
      emergencyType: json['emergency_type'] as String?,
      recommendedDept: json['recommended_dept'] as String? ?? 'General Practitioner',
      warningMessage: json['warning_message'] as String? ?? '',
      sosRequired: json['sos_required'] as bool? ?? false,
      firstAid: firstAid,
      hospitalRecommendations: hospitals,
      matchedKeywords: List<String>.from(json['matched_keywords'] as List? ?? []),
      mlConfidence: (json['ml_confidence'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
