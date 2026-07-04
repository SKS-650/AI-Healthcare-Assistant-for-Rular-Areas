import 'package:flutter/material.dart';

import '../../../domain/entities/prescription.dart';
import 'dosage_chip.dart';

class MedicineTile extends StatelessWidget {
  final MedicineDosage medicine;

  const MedicineTile({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.medication_outlined),
      title: Text(medicine.name),
      subtitle: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          DosageChip(label: medicine.dose),
          DosageChip(label: medicine.frequency),
          DosageChip(label: medicine.duration),
        ],
      ),
    );
  }
}
