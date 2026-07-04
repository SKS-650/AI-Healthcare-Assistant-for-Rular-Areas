import '../../../domain/entities/prediction.dart';
import '../../../domain/entities/symptom.dart';

class PredictApi {
  const PredictApi();

  Future<Prediction> predict({
    required List<Symptom> symptoms,
    required double severity,
  }) async {
    final ids = symptoms.map((symptom) => symptom.id).toSet();
    final hasRespiratory = ids.contains('cough') ||
        ids.contains('sore_throat') ||
        ids.contains('breathing');
    final hasFluPattern = ids.contains('fever') &&
        (ids.contains('cough') || ids.contains('fatigue'));

    final condition = ids.contains('breathing')
        ? 'Possible respiratory distress'
        : hasFluPattern
            ? 'Possible flu-like illness'
            : hasRespiratory
                ? 'Possible upper respiratory infection'
                : ids.contains('headache')
                    ? 'Possible tension headache'
                    : 'General wellness concern';

    final riskLevel = ids.contains('breathing') || severity >= 8
        ? RiskLevel.high
        : symptoms.length >= 3 || severity >= 5
            ? RiskLevel.moderate
            : RiskLevel.low;

    final confidence = (0.45 + (symptoms.length * 0.08) + (severity / 25))
        .clamp(0.45, 0.96)
        .toDouble();

    return Prediction(
      condition: condition,
      confidence: confidence,
      riskLevel: riskLevel,
      recommendation: _recommendationFor(riskLevel),
      matchedSymptoms: symptoms.map((symptom) => symptom.name).toList(),
      createdAt: DateTime.now(),
    );
  }

  String _recommendationFor(RiskLevel riskLevel) {
    return switch (riskLevel) {
      RiskLevel.high =>
        'Seek urgent medical care, especially if symptoms are worsening.',
      RiskLevel.moderate =>
        'Monitor symptoms closely and consult a clinician if they persist.',
      RiskLevel.low =>
        'Rest, hydrate, and continue observing symptoms for changes.',
    };
  }
}
