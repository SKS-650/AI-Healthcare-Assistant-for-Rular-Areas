import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.sender,
    required super.createdAt,
    super.isVoiceMessage,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: (json['sender'] as String) == 'user'
          ? ChatSender.user
          : ChatSender.bot,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isVoiceMessage: json['isVoiceMessage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender.name,
      'createdAt': createdAt.toIso8601String(),
      'isVoiceMessage': isVoiceMessage,
    };
  }
}
