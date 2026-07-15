import '../../domain/entities/offline_symptom_result.dart';

class OfflineSymptomResultModel extends OfflineSymptomResult {
  const OfflineSymptomResultModel({
    required super.id,
    required super.symptoms,
    required super.primaryDisease,
    required super.confidence,
    required super.riskLevel,
    required super.topDiseases,
    required super.recommendations,
    required super.dietRecommendations,
    required super.precautions,
    required super.workouts,
    required super.isEmergency,
    required super.criticalSymptoms,
    required super.createdAt,
    super.age,
    super.gender,
    super.isSynced,
  });

  factory OfflineSymptomResultModel.fromJson(Map<String, dynamic> json) {
    return OfflineSymptomResultModel(
      id:              json['id'] as String,
      symptoms:        List<String>.from(json['symptoms'] as List),
      primaryDisease:  json['primary_disease'] as String,
      confidence:      (json['confidence'] as num).toDouble(),
      riskLevel:       json['risk_level'] as String,
      topDiseases: (json['top_diseases'] as List).map((e) {
        final m = e as Map<String, dynamic>;
        return DiseaseConfidencePair(
          disease:    m['disease'] as String,
          confidence: (m['confidence'] as num).toDouble(),
        );
      }).toList(),
      recommendations:     List<String>.from(json['recommendations'] as List),
      dietRecommendations: List<String>.from(json['diet_recommendations'] as List),
      precautions:         List<String>.from(json['precautions'] as List),
      workouts:            List<String>.from(json['workouts'] as List),
      isEmergency:         json['is_emergency'] as bool,
      criticalSymptoms:    List<String>.from(json['critical_symptoms'] as List),
      createdAt:           DateTime.parse(json['created_at'] as String),
      age:                 json['age'] as int?,
      gender:              json['gender'] as String?,
      isSynced:            json['is_synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':               id,
        'symptoms':         symptoms,
        'primary_disease':  primaryDisease,
        'confidence':       confidence,
        'risk_level':       riskLevel,
        'top_diseases': topDiseases
            .map((d) => {'disease': d.disease, 'confidence': d.confidence})
            .toList(),
        'recommendations':      recommendations,
        'diet_recommendations': dietRecommendations,
        'precautions':          precautions,
        'workouts':             workouts,
        'is_emergency':         isEmergency,
        'critical_symptoms':    criticalSymptoms,
        'created_at':           createdAt.toIso8601String(),
        'age':                  age,
        'gender':               gender,
        'is_synced':            isSynced,
      };
}
