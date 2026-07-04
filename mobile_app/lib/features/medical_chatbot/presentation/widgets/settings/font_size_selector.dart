import 'package:flutter/material.dart';

class FontSizeSelector extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const FontSizeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<double>(
      segments: const [
        ButtonSegment(value: 14, label: Text('S')),
        ButtonSegment(value: 16, label: Text('M')),
        ButtonSegment(value: 18, label: Text('L')),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
