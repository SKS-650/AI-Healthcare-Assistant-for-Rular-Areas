import 'package:equatable/equatable.dart';

class Lifestyle extends Equatable {
  final String smokingHabit;
  final String alcoholConsumption;
  final String exerciseFrequency;
  final int averageSleepHours;

  const Lifestyle({
    required this.smokingHabit,
    required this.alcoholConsumption,
    required this.exerciseFrequency,
    required this.averageSleepHours,
  });

  @override
  List<Object?> get props => [
        smokingHabit,
        alcoholConsumption,
        exerciseFrequency,
        averageSleepHours,
      ];
}