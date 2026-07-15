import '../../domain/entities/language.dart';

class LanguageModel extends Language {
  const LanguageModel({
    required super.code,
    required super.name,
    required super.nativeName,
    super.flag,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code:       json['code']       as String,
      name:       json['name']       as String,
      nativeName: json['nativeName'] as String,
      flag:       json['flag']       as String? ?? '🌐',
    );
  }

  factory LanguageModel.fromLanguage(Language lang) {
    return LanguageModel(
      code:       lang.code,
      name:       lang.name,
      nativeName: lang.nativeName,
      flag:       lang.flag,
    );
  }

  Map<String, dynamic> toJson() => {
    'code':       code,
    'name':       name,
    'nativeName': nativeName,
    'flag':       flag,
  };
}
