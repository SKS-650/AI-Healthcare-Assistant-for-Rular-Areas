import '../../domain/entities/selected_symptom.dart';
import 'symptom_model.dart';

class SelectedSymptomModel extends SelectedSymptom {
  const SelectedSymptomModel({
    required SymptomModel super.symptom,
    required super.severity, // 1 to 10 scale
    required super.durationInDays,
  });

  factory SelectedSymptomModel.fromJson(Map<String, dynamic> json) {
    return SelectedSymptomModel(
      symptom: SymptomModel.fromJson(json['symptom'] as Map<String, dynamic>),
      severity: (json['severity'] as num).toDouble(),
      durationInDays: json['durationInDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symptom': SymptomModel.fromEntity(symptom).toJson(),
      'severity': severity,
      'durationInDays': durationInDays,
    };
  }

  factory SelectedSymptomModel.fromEntity(SelectedSymptom entity) {
    return SelectedSymptomModel(
      symptom: SymptomModel.fromEntity(entity.symptom),
      severity: entity.severity,
      durationInDays: entity.durationInDays,
    );
  }
}