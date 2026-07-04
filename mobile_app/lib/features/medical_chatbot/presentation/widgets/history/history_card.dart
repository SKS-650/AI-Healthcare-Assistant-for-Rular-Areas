import 'package:flutter/material.dart';

import '../../../domain/entities/conversation.dart';
import 'history_tile.dart';

class HistoryCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;

  const HistoryCard({super.key, required this.conversation, this.onTap});

  @override
  Widget build(BuildContext context) {
    return HistoryTile(conversation: conversation, onTap: onTap);
  }
}
