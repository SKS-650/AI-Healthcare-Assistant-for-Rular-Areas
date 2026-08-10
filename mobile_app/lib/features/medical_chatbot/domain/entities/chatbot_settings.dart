import 'language.dart';
import 'voice_type.dart';

class ChatbotSettings {
  final Language language;
  final bool voiceResponsesEnabled;
  final double voiceSpeed;
  final VoiceType voiceType;
  final double fontSize;
  final bool saveHistory;

  const ChatbotSettings({
    required this.language,
    this.voiceResponsesEnabled = true,
    this.voiceSpeed = 1.0,
    this.voiceType = VoiceType.neutral,
    this.fontSize = 16,
    this.saveHistory = true,
  });
}
