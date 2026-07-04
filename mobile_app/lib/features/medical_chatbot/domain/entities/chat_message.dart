enum ChatSender { user, bot }

class ChatMessage {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime createdAt;
  final bool isVoiceMessage;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
    this.isVoiceMessage = false,
  });
}
