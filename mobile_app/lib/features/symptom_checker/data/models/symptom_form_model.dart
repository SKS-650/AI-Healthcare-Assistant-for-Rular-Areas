import '../../domain/entities/symptom_form.dart';
import 'selected_symptom_model.dart';
import 'medical_history_model.dart';
import 'lifestyle_model.dart';

class SymptomFormModel extends SymptomForm {
  const SymptomFormModel({
    required List<SelectedSymptomModel> super.selectedSymptoms,
    required super.age,
    required super.gender,
    required MedicalHistoryModel super.medicalHistory,
    required LifestyleModel super.lifestyle,
  });

  factory SymptomFormModel.fromJson(Map<String, dynamic> json) {
    return SymptomFormModel(
      selectedSymptoms: (json['selectedSymptoms'] as List)
          .map((e) => SelectedSymptomModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      age: json['age'] as int,
      gender: json['gender'] as String,
      medicalHistory: MedicalHistoryModel.fromJson(json['medicalHistory'] as Map<String, dynamic>),
      lifestyle: LifestyleModel.fromJson(json['lifestyle'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedSymptoms': selectedSymptoms.map((e) => SelectedSymptomModel.fromEntity(e).toJson()).toList(),
      'age': age,
      'gender': gender,
      'medicalHistory': MedicalHistoryModel.fromEntity(medicalHistory).toJson(),
      'lifestyle': LifestyleModel.fromEntity(lifestyle).toJson(),
    };
  }

  factory SymptomFormModel.fromEntity(SymptomForm entity) {
    return SymptomFormModel(
      selectedSymptoms: entity.selectedSymptoms.map((e) => SelectedSymptomModel.fromEntity(e)).toList(),
      age: entity.age,
      gender: entity.gender,
      medicalHistory: MedicalHistoryModel.fromEntity(entity.medicalHistory),
      lifestyle: LifestyleModel.fromEntity(entity.lifestyle),
    );
  }
}