import '../../domain/entities/chatbot_settings.dart';
import '../../domain/entities/language.dart';
import 'language_model.dart';

class ChatbotSettingsModel extends ChatbotSettings {
  const ChatbotSettingsModel({
    required super.language,
    super.voiceResponsesEnabled,
    super.voiceSpeed,
    super.fontSize,
    super.saveHistory,
  });

  factory ChatbotSettingsModel.fromJson(Map<String, dynamic> json) {
    return ChatbotSettingsModel(
      language: LanguageModel.fromJson(
        json['language'] as Map<String, dynamic>,
      ),
      voiceResponsesEnabled: json['voiceResponsesEnabled'] as bool? ?? true,
      voiceSpeed: (json['voiceSpeed'] as num?)?.toDouble() ?? 1.0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16,
      saveHistory: json['saveHistory'] as bool? ?? true,
    );
  }

  factory ChatbotSettingsModel.fromEntity(ChatbotSettings settings) {
    return ChatbotSettingsModel(
      language: LanguageModel(
        code: settings.language.code,
        name: settings.language.name,
        nativeName: settings.language.nativeName,
      ),
      voiceResponsesEnabled: settings.voiceResponsesEnabled,
      voiceSpeed: settings.voiceSpeed,
      fontSize: settings.fontSize,
      saveHistory: settings.saveHistory,
    );
  }

  ChatbotSettingsModel copyWith({
    Language? language,
    bool? voiceResponsesEnabled,
    double? voiceSpeed,
    double? fontSize,
    bool? saveHistory,
  }) {
    return ChatbotSettingsModel(
      language: language ?? this.language,
      voiceResponsesEnabled:
          voiceResponsesEnabled ?? this.voiceResponsesEnabled,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
      fontSize: fontSize ?? this.fontSize,
      saveHistory: saveHistory ?? this.saveHistory,
    );
  }

  Map<String, dynamic> toJson() {
    final currentLanguage = language;
    return {
      'language': LanguageModel(
        code: currentLanguage.code,
        name: currentLanguage.name,
        nativeName: currentLanguage.nativeName,
      ).toJson(),
      'voiceResponsesEnabled': voiceResponsesEnabled,
      'voiceSpeed': voiceSpeed,
      'fontSize': fontSize,
      'saveHistory': saveHistory,
    };
  }
}
