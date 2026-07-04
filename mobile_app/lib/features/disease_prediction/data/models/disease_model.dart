import '../../domain/entities/disease.dart';

class DiseaseModel extends Disease {
  const DiseaseModel({
    required super.id,
    required super.name,
    required super.shortDescription,
    required super.overview,
    required super.symptoms,
    required super.causes,
    required super.imageUrl,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortDescription: json['shortDescription'] as String,
      overview: json['overview'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      causes: List<String>.from(json['causes'] as List),
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'overview': overview,
      'symptoms': symptoms,
      'causes': causes,
      'imageUrl': imageUrl,
    };
  }
}
