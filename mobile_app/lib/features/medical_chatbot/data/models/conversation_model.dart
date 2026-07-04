import '../../domain/entities/conversation.dart';
import 'chat_message_model.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.title,
    required super.messages,
    required super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List)
          .map(
            (item) => ChatMessageModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages
          .map(
            (item) => ChatMessageModel(
              id: item.id,
              text: item.text,
              sender: item.sender,
              createdAt: item.createdAt,
              isVoiceMessage: item.isVoiceMessage,
            ).toJson(),
          )
          .toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
