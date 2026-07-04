import '../../domain/entities/first_aid.dart';

class FirstAidModel extends FirstAid {
  const FirstAidModel({
    required super.id,
    required super.title,
    required super.category,
    required super.summary,
    required super.steps,
  });

  factory FirstAidModel.fromJson(Map<String, dynamic> json) {
    return FirstAidModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      steps: (json['steps'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'summary': summary,
      'steps': steps,
    };
  }
}
