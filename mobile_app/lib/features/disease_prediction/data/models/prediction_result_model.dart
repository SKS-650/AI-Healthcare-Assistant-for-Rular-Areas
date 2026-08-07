import '../../domain/entities/prediction_result.dart';
import 'disease_model.dart';
import 'recommendation_model.dart';

class PredictionResultModel extends PredictionResult {
  const PredictionResultModel({
    required super.id,
    required super.disease,
    required super.confidence,
    required super.riskLevel,
    required super.probabilities,
    required super.recommendation,
    required super.createdAt,
    super.riskScore = 0.0,
    super.riskFactors = const [],
    super.criticalSymptoms = const [],
    super.isEmergency = false,
    super.emergencyAlert,
    super.topDiseases = const [],
    super.bmi,
    super.bmiCategory,
    super.durationCategory,
    super.severityLabel,
    super.existingConditions = const [],
    super.medications = const [],
    super.allergies = const [],
    super.augmentationLog = const [],
    super.augmentedSymptomCount,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    return PredictionResultModel(
      id: json['id'] as String,
      disease: DiseaseModel.fromJson(json['disease'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      probabilities: Map<String, double>.from(
        (json['probabilities'] as Map).map(
          (key, value) =>
              MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      recommendation: RecommendationModel.fromJson(
        json['recommendation'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
      riskFactors: List<String>.from(json['riskFactors'] as List? ?? []),
      criticalSymptoms:
          List<String>.from(json['criticalSymptoms'] as List? ?? []),
      isEmergency: json['isEmergency'] as bool? ?? false,
      emergencyAlert: json['emergencyAlert'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disease': (disease as DiseaseModel).toJson(),
      'confidence': confidence,
      'riskLevel': riskLevel,
      'probabilities': probabilities,
      'recommendation': (recommendation as RecommendationModel).toJson(),
      'createdAt': createdAt.toIso8601String(),
      'riskScore': riskScore,
      'riskFactors': riskFactors,
      'criticalSymptoms': criticalSymptoms,
      'isEmergency': isEmergency,
      if (emergencyAlert != null) 'emergencyAlert': emergencyAlert,
    };
  }
}
