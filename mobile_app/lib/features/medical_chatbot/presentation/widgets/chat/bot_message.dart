import 'package:flutter/material.dart';

import '../../../domain/entities/chat_message.dart';
import 'message_bubble.dart';

class BotMessage extends StatelessWidget {
  final ChatMessage message;

  const BotMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) => MessageBubble(message: message);
}
