import 'package:flutter/material.dart';

import '../../../domain/entities/emergency_history.dart';

class EmergencyHistoryCard extends StatelessWidget {
  final EmergencyHistory history;

  const EmergencyHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          history.event.sosSent ? Icons.sos_rounded : Icons.history_rounded,
          color: Colors.red.shade600,
        ),
        title: Text(history.event.type.title),
        subtitle: Text('${history.actionTaken}\n${history.event.location}'),
        isThreeLine: true,
        trailing: Text(
          TimeOfDay.fromDateTime(history.savedAt).format(context),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
