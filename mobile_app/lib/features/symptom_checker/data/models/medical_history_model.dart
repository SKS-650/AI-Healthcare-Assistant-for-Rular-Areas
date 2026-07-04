import '../../domain/entities/medical_history.dart';

class MedicalHistoryModel extends MedicalHistory {
  const MedicalHistoryModel({
    required super.chronicConditions,
    required super.allergies,
    required super.currentMedications,
  });

  factory MedicalHistoryModel.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryModel(
      chronicConditions: List<String>.from(json['chronicConditions'] as List),
      allergies: List<String>.from(json['allergies'] as List),
      currentMedications: List<String>.from(json['currentMedications'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chronicConditions': chronicConditions,
      'allergies': allergies,
      'currentMedications': currentMedications,
    };
  }

  factory MedicalHistoryModel.fromEntity(MedicalHistory entity) {
    return MedicalHistoryModel(
      chronicConditions: entity.chronicConditions,
      allergies: entity.allergies,
      currentMedications: entity.currentMedications,
    );
  }
}