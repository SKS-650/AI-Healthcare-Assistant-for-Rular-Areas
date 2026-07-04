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

  const PredictionResult({
    required this.id,
    required this.disease,
    required this.confidence,
    required this.riskLevel,
    required this.probabilities,
    required this.recommendation,
    required this.createdAt,
  });
}
