import 'package:equatable/equatable.dart';
import 'selected_symptom.dart';
import 'medical_history.dart';
import 'lifestyle.dart';

class SymptomForm extends Equatable {
  final List<SelectedSymptom> selectedSymptoms;
  final int age;
  final String gender;
  final MedicalHistory medicalHistory;
  final Lifestyle lifestyle;

  const SymptomForm({
    required this.selectedSymptoms,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    required this.lifestyle,
  });

  @override
  List<Object?> get props => [
        selectedSymptoms,
        age,
        gender,
        medicalHistory,
        lifestyle,
      ];
}