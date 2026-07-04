import '../../domain/entities/symptom.dart';

class SymptomModel extends Symptom {
  const SymptomModel({
    required super.id,
    required super.name,
    required super.category,
    required super.description,
  });

  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
    };
  }

  factory SymptomModel.fromEntity(Symptom entity) {
    return SymptomModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      description: entity.description,
    );
  }
}