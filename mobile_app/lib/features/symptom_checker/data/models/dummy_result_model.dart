import '../../domain/entities/prediction_result.dart';

class DummyResultModel extends PredictionResult {
  const DummyResultModel({
    required super.conditionName,
    required super.confidenceScore,
    required super.riskLevel,
    required super.description,
    required super.recommendations,
  });

  factory DummyResultModel.fromJson(Map<String, dynamic> json) {
    return DummyResultModel(
      conditionName: json['conditionName'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      description: json['description'] as String,
      recommendations: List<String>.from(json['recommendations'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditionName': conditionName,
      'confidenceScore': confidenceScore,
      'riskLevel': riskLevel,
      'description': description,
      'recommendations': recommendations,
    };
  }
}