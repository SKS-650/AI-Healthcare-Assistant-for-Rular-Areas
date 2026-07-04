import '../../domain/entities/suggestion.dart';

class SuggestionModel extends Suggestion {
  const SuggestionModel({
    required super.id,
    required super.text,
    required super.category,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'category': category};
  }
}
