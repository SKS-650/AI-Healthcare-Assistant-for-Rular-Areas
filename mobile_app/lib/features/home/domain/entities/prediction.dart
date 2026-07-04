// lib/features/home/domain/entities/prediction.dart
class Prediction {
  final String id;
  final String diseaseName;
  final double confidence;
  final DateTime date;

  const Prediction({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.date,
  });
}