import 'package:flutter/material.dart';

import '../../../domain/entities/prescription.dart';
import 'medicine_tile.dart';

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionCard({super.key, required this.prescription});

  String _format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prescription.diagnosis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${prescription.doctor.name} • ${_format(prescription.prescribedAt)}',
            ),
            const Divider(height: 24),
            ...prescription.medicines.map(
              (item) => MedicineTile(medicine: item),
            ),
            Text(prescription.instructions),
          ],
        ),
      ),
    );
  }
}
