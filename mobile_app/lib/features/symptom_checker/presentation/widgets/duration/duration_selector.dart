import 'package:flutter/material.dart';

class DurationSelector extends StatelessWidget {
  final int currentDays;
  final ValueChanged<int> onChanged;

  const DurationSelector({
    super.key,
    required this.currentDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: currentDays > 1 ? () => onChanged(currentDays - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$currentDays ${currentDays == 1 ? 'Day' : 'Days'}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        IconButton(
          onPressed: () => onChanged(currentDays + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}