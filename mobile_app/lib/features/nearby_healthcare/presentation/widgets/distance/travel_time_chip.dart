import 'package:flutter/material.dart';

class TravelTimeChip extends StatelessWidget {
  final int minutes;

  const TravelTimeChip({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.directions_car_outlined, size: 18),
      label: Text('$minutes min'),
      visualDensity: VisualDensity.compact,
    );
  }
}
