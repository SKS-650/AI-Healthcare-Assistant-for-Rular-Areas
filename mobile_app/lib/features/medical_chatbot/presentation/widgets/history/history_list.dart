import 'package:flutter/material.dart';

import '../../../domain/entities/conversation.dart';
import '../common/empty_state.dart';
import 'history_card.dart';

class HistoryList extends StatelessWidget {
  final List<Conversation> conversations;
  final ValueChanged<Conversation>? onSelected;

  const HistoryList({super.key, required this.conversations, this.onSelected});

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return const ChatbotEmptyState(
        icon: Icons.history_rounded,
        title: 'No saved chats',
        message: 'Conversations will appear here after you send messages.',
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return HistoryCard(
          conversation: conversation,
          onTap: onSelected == null ? null : () => onSelected!(conversation),
        );
      },
    );
  }
}
