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
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    return PredictionResultModel(
      id: json['id'] as String,
      disease: DiseaseModel.fromJson(json['disease'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      probabilities: Map<String, double>.from(
        (json['probabilities'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      recommendation: RecommendationModel.fromJson(
        json['recommendation'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
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
    };
  }
}
