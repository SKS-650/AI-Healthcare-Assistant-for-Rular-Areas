import '../../domain/entities/lifestyle.dart';

class LifestyleModel extends Lifestyle {
  const LifestyleModel({
    required super.smokingHabit,
    required super.alcoholConsumption,
    required super.exerciseFrequency,
    required super.averageSleepHours,
  });

  factory LifestyleModel.fromJson(Map<String, dynamic> json) {
    return LifestyleModel(
      smokingHabit: json['smokingHabit'] as String? ?? 'Never',
      alcoholConsumption: json['alcoholConsumption'] as String? ?? 'Never',
      exerciseFrequency: json['exerciseFrequency'] as String? ?? 'Medium',
      averageSleepHours: (json['averageSleepHours'] as num?)?.toInt() ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smokingHabit': smokingHabit,
      'alcoholConsumption': alcoholConsumption,
      'exerciseFrequency': exerciseFrequency,
      'averageSleepHours': averageSleepHours,
    };
  }

  factory LifestyleModel.fromEntity(Lifestyle entity) {
    return LifestyleModel(
      smokingHabit: entity.smokingHabit,
      alcoholConsumption: entity.alcoholConsumption,
      exerciseFrequency: entity.exerciseFrequency,
      averageSleepHours: entity.averageSleepHours,
    );
  }
}