import 'package:flutter/material.dart';

class EmergencyAnimation extends StatelessWidget {
  final bool active;

  const EmergencyAnimation({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 96 : 76,
      height: active ? 96 : 76,
      decoration: BoxDecoration(
        color: active ? Colors.red.shade100 : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        active ? Icons.radar_rounded : Icons.health_and_safety_outlined,
        color: active ? Colors.red.shade700 : Colors.grey.shade700,
        size: 42,
      ),
    );
  }
}
