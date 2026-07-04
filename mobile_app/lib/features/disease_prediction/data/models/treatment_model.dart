import '../../domain/entities/treatment.dart';

class TreatmentModel extends Treatment {
  const TreatmentModel({
    required super.id,
    required super.title,
    required super.description,
    required super.duration,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: json['duration'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
    };
  }
}
