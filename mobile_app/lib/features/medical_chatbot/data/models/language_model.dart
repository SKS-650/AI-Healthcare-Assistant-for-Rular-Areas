import '../../domain/entities/language.dart';

class LanguageModel extends Language {
  const LanguageModel({
    required super.code,
    required super.name,
    required super.nativeName,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'nativeName': nativeName};
  }
}
