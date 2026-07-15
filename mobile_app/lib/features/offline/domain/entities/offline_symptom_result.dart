/// The result of an offline (on-device) symptom assessment.
class OfflineSymptomResult {
  const OfflineSymptomResult({
    required this.id,
    required this.symptoms,
    required this.primaryDisease,
    required this.confidence,
    required this.riskLevel,
    required this.topDiseases,
    required this.recommendations,
    required this.dietRecommendations,
    required this.precautions,
    required this.workouts,
    required this.isEmergency,
    required this.criticalSymptoms,
    required this.createdAt,
    this.age,
    this.gender,
    this.isSynced = false,
  });

  final String id;
  final List<String> symptoms;
  final String primaryDisease;
  final double confidence;

  /// 'low' | 'medium' | 'high' | 'critical'
  final String riskLevel;

  final List<DiseaseConfidencePair> topDiseases;
  final List<String> recommendations;
  final List<String> dietRecommendations;
  final List<String> precautions;
  final List<String> workouts;
  final bool isEmergency;
  final List<String> criticalSymptoms;
  final DateTime createdAt;
  final int? age;
  final String? gender;

  /// Whether this result has been uploaded to the server.
  final bool isSynced;

  OfflineSymptomResult copyWith({bool? isSynced}) => OfflineSymptomResult(
        id:                   id,
        symptoms:             symptoms,
        primaryDisease:       primaryDisease,
        confidence:           confidence,
        riskLevel:            riskLevel,
        topDiseases:          topDiseases,
        recommendations:      recommendations,
        dietRecommendations:  dietRecommendations,
        precautions:          precautions,
        workouts:             workouts,
        isEmergency:          isEmergency,
        criticalSymptoms:     criticalSymptoms,
        createdAt:            createdAt,
        age:                  age,
        gender:               gender,
        isSynced:             isSynced ?? this.isSynced,
      );
}

class DiseaseConfidencePair {
  const DiseaseConfidencePair({required this.disease, required this.confidence});
  final String disease;
  final double confidence;
}
