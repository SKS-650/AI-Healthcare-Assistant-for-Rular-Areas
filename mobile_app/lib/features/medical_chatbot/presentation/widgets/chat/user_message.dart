import 'package:flutter/material.dart';

import '../../../domain/entities/chat_message.dart';
import 'message_bubble.dart';

class UserMessage extends StatelessWidget {
  final ChatMessage message;

  const UserMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) => MessageBubble(message: message);
}
