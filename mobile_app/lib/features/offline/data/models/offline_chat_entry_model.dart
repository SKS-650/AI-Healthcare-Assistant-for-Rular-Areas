import '../../domain/entities/offline_chat_entry.dart';
import '../../domain/enums/offline_enums.dart';

class OfflineChatEntryModel extends OfflineChatEntry {
  const OfflineChatEntryModel({
    required super.id,
    required super.userMessage,
    required super.botResponse,
    required super.source,
    required super.createdAt,
    super.conversationId,
    super.isSynced,
  });

  factory OfflineChatEntryModel.fromJson(Map<String, dynamic> json) =>
      OfflineChatEntryModel(
        id:             json['id'] as String,
        userMessage:    json['user_message'] as String,
        botResponse:    json['bot_response'] as String,
        source:         ChatbotSource.values.byName(json['source'] as String),
        createdAt:      DateTime.parse(json['created_at'] as String),
        conversationId: json['conversation_id'] as String?,
        isSynced:       json['is_synced'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id':              id,
        'user_message':    userMessage,
        'bot_response':    botResponse,
        'source':          source.name,
        'created_at':      createdAt.toIso8601String(),
        'conversation_id': conversationId,
        'is_synced':       isSynced,
      };
}
