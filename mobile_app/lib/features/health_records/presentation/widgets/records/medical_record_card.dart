import 'package:flutter/material.dart';

import '../../../domain/entities/medical_record.dart';
import 'record_status_badge.dart';

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback? onTap;

  const MedicalRecordCard({super.key, required this.record, this.onTap});

  String _format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.description_outlined),
        ),
        title: Text(
          record.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${record.category} • ${record.doctor.name}'),
              const SizedBox(height: 4),
              Text(_format(record.date)),
            ],
          ),
        ),
        trailing: RecordStatusBadge(status: record.status),
      ),
    );
  }
}
