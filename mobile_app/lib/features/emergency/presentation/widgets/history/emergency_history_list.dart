import 'package:flutter/material.dart';

import '../../../domain/entities/emergency_history.dart';
import '../common/empty_state.dart';
import 'emergency_history_card.dart';

class EmergencyHistoryList extends StatelessWidget {
  final List<EmergencyHistory> history;

  const EmergencyHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const EmergencyEmptyState(
        icon: Icons.history_rounded,
        title: 'No emergency history',
        message: 'SOS alerts and detected emergencies will appear here.',
      );
    }
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) =>
          EmergencyHistoryCard(history: history[index]),
    );
  }
}
