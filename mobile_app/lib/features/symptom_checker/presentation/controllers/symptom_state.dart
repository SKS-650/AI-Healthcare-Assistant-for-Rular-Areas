import 'package:equatable/equatable.dart';
import '../../domain/entities/symptom.dart';
import '../../domain/entities/selected_symptom.dart';
import '../../domain/entities/prediction_result.dart';

enum SymptomStatus { initial, loading, success, failure }

class SymptomState extends Equatable {
  final SymptomStatus status;
  final List<Symptom> availableSymptoms;
  final List<SelectedSymptom> selectedSymptoms;
  
  // Form step parameters
  final int currentStep; // 0: Selection, 1: Severity, 2: Duration, 3: Personal, 4: History, 5: Lifestyle, 6: Review
  final int age;
  final String gender;
  final List<String> chronicConditions;
  final List<String> allergies;
  final List<String> currentMedications;
  final String smokingHabit;
  final String alcoholConsumption;
  final String exerciseFrequency;
  final int averageSleepHours;
  
  final PredictionResult? predictionResult;
  final String? errorMessage;

  const SymptomState({
    this.status = SymptomStatus.initial,
    this.availableSymptoms = const [],
    this.selectedSymptoms = const [],
    this.currentStep = 0,
    this.age = 25,
    this.gender = 'Male',
    this.chronicConditions = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.smokingHabit = 'Never',
    this.alcoholConsumption = 'Never',
    this.exerciseFrequency = 'Medium',
    this.averageSleepHours = 7,
    this.predictionResult,
    this.errorMessage,
  });

  SymptomState copyWith({
    SymptomStatus? status,
    List<Symptom>? availableSymptoms,
    List<SelectedSymptom>? selectedSymptoms,
    int? currentStep,
    int? age,
    String? gender,
    List<String>? chronicConditions,
    List<String>? allergies,
    List<String>? currentMedications,
    String? smokingHabit,
    String? alcoholConsumption,
    String? exerciseFrequency,
    int? averageSleepHours,
    PredictionResult? predictionResult,
    String? errorMessage,
  }) {
    return SymptomState(
      status: status ?? this.status,
      availableSymptoms: availableSymptoms ?? this.availableSymptoms,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      currentStep: currentStep ?? this.currentStep,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      alcoholConsumption: alcoholConsumption ?? this.alcoholConsumption,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      averageSleepHours: averageSleepHours ?? this.averageSleepHours,
      predictionResult: predictionResult ?? this.predictionResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        availableSymptoms,
        selectedSymptoms,
        currentStep,
        age,
        gender,
        chronicConditions,
        allergies,
        currentMedications,
        smokingHabit,
        alcoholConsumption,
        exerciseFrequency,
        averageSleepHours,
        predictionResult,
        errorMessage,
      ];
}