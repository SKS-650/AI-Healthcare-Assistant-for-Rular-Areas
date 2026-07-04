import 'package:flutter/material.dart';

class DosageChip extends StatelessWidget {
  final String label;

  const DosageChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      avatar: const Icon(Icons.schedule, size: 16),
    );
  }
}
