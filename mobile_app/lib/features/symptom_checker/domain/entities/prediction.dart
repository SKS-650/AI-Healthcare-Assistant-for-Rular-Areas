enum RiskLevel { low, moderate, high }

class Prediction {
  const Prediction({
    required this.condition,
    required this.confidence,
    required this.riskLevel,
    required this.recommendation,
    required this.matchedSymptoms,
    required this.createdAt,
  });

  final String condition;
  final double confidence;
  final RiskLevel riskLevel;
  final String recommendation;
  final List<String> matchedSymptoms;
  final DateTime createdAt;

  static Prediction empty() {
    return Prediction(
      condition: 'No prediction available',
      confidence: 0,
      riskLevel: RiskLevel.low,
      recommendation: 'Select symptoms to generate a prediction.',
      matchedSymptoms: const [],
      createdAt: DateTime.now(),
    );
  }
}
