import 'package:equatable/equatable.dart';

class MedicalHistory extends Equatable {
  final List<String> chronicConditions;
  final List<String> allergies;
  final List<String> currentMedications;

  const MedicalHistory({
    required this.chronicConditions,
    required this.allergies,
    required this.currentMedications,
  });

  @override
  List<Object?> get props => [chronicConditions, allergies, currentMedications];
}