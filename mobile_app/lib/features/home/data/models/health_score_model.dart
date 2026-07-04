// lib/features/home/data/models/health_score_model.dart
import '../../domain/entities/health_score.dart';

class HealthScoreModel extends HealthScore {
  const HealthScoreModel({
    required super.score,
    required super.status,
    required super.description,
  });

  factory HealthScoreModel.fromJson(Map<String, dynamic> json) {
    return HealthScoreModel(
      score: json['score'] as int,
      status: json['status'] as String,
      description: json['description'] as String,
    );
  }
}