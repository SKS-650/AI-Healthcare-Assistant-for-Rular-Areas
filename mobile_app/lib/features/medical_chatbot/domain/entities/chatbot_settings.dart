import 'language.dart';

class ChatbotSettings {
  final Language language;
  final bool voiceResponsesEnabled;
  final double voiceSpeed;
  final double fontSize;
  final bool saveHistory;

  const ChatbotSettings({
    required this.language,
    this.voiceResponsesEnabled = true,
    this.voiceSpeed = 1.0,
    this.fontSize = 16,
    this.saveHistory = true,
  });
}
