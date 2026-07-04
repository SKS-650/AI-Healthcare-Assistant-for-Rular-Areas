import 'package:flutter/material.dart';

import '../../../domain/entities/medical_timeline.dart';

class TimelineCard extends StatelessWidget {
  final MedicalTimeline item;

  const TimelineCard({super.key, required this.item});

  String _format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${item.type} • ${item.doctorName} • ${_format(item.occurredAt)}',
            ),
          ],
        ),
      ),
    );
  }
}
