import 'package:flutter/material.dart';

class SeveritySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const SeveritySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      min: 1.0,
      max: 10.0,
      divisions: 9,
      label: value.toStringAsFixed(0),
      activeColor: Color.lerp(Colors.green, Colors.red, value / 10),
      onChanged: onChanged,
    );
  }
}