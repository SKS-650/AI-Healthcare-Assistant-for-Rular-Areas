import 'package:equatable/equatable.dart';

class PredictionResult extends Equatable {
  final String conditionName;
  final double confidenceScore; // Range: 0.0 to 1.0
  final String riskLevel;       // e.g., Low, Medium, High
  final String description;
  final List<String> recommendations;

  const PredictionResult({
    required this.conditionName,
    required this.confidenceScore,
    required this.riskLevel,
    required this.description,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [
        conditionName,
        confidenceScore,
        riskLevel,
        description,
        recommendations,
      ];
}