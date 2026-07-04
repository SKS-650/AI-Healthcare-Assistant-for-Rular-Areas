import '../../domain/entities/prevention.dart';

class PreventionModel extends Prevention {
  const PreventionModel({
    required super.id,
    required super.title,
    required super.description,
  });

  factory PreventionModel.fromJson(Map<String, dynamic> json) {
    return PreventionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'description': description};
  }
}
