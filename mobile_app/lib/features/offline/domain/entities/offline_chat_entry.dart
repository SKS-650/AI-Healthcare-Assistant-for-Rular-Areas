import '../enums/offline_enums.dart';

/// A single offline chatbot exchange stored locally.
class OfflineChatEntry {
  const OfflineChatEntry({
    required this.id,
    required this.userMessage,
    required this.botResponse,
    required this.source,
    required this.createdAt,
    this.conversationId,
    this.isSynced = false,
  });

  final String id;
  final String userMessage;
  final String botResponse;
  final ChatbotSource source;
  final DateTime createdAt;
  final String? conversationId;
  final bool isSynced;
}
