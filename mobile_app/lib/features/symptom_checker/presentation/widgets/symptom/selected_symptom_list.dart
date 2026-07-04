import 'package:flutter/material.dart';
import '../../../domain/entities/selected_symptom.dart';

class SelectedSymptomList extends StatelessWidget {
  final List<SelectedSymptom> items;
  final Function(String) onRemove;

  const SelectedSymptomList({
    super.key,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selected Symptoms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) {
            return InputChip(
              label: Text(item.symptom.name),
              onDeleted: () => onRemove(item.symptom.id),
              deleteIconColor: Colors.red[400],
              backgroundColor: Colors.grey[100],
            );
          }).toList(),
        ),
      ],
    );
  }
}