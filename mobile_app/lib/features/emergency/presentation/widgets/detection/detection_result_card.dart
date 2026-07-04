import 'package:flutter/material.dart';

import '../../../domain/entities/emergency_event.dart';

class DetectionResultCard extends StatelessWidget {
  final EmergencyEvent event;
  final VoidCallback? onSosPressed;

  const DetectionResultCard({
    super.key,
    required this.event,
    this.onSosPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.type.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(event.type.description),
            const SizedBox(height: 12),
            Chip(label: Text('Severity: ${event.type.severity}')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSosPressed,
                icon: const Icon(Icons.sos_rounded),
                label: const Text('Send SOS for this emergency'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
