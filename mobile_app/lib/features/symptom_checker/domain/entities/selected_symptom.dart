import 'package:equatable/equatable.dart';
import 'symptom.dart';

class SelectedSymptom extends Equatable {
  final Symptom symptom;
  final double severity; // 1.0 to 10.0 scale
  final int durationInDays;

  const SelectedSymptom({
    required this.symptom,
    required this.severity,
    required this.durationInDays,
  });

  @override
  List<Object?> get props => [symptom, severity, durationInDays];
}