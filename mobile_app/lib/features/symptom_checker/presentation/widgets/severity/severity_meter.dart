import 'package:flutter/material.dart';

class SeverityMeter extends StatelessWidget {
  final double value;

  const SeverityMeter({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    Color meterColor = Colors.green;
    String label = 'Mild';

    if (value >= 4 && value <= 7) {
      meterColor = Colors.orange;
      label = 'Moderate';
    } else if (value > 7) {
      meterColor = Colors.red;
      label = 'Severe';
    }

    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: meterColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label (Level ${value.toStringAsFixed(0)})',
          style: TextStyle(color: meterColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}