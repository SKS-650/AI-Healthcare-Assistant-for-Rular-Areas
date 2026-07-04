import 'package:flutter/material.dart';

class VoiceSpeedSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VoiceSpeedSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      min: 0.6,
      max: 1.6,
      divisions: 10,
      label: '${value.toStringAsFixed(1)}x',
      onChanged: onChanged,
    );
  }
}
