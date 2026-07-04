import 'package:flutter/material.dart';

import '../../domain/entities/prediction.dart';

class RiskIndicator extends StatelessWidget {
  const RiskIndicator({required this.riskLevel, super.key});

  final RiskLevel riskLevel;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (riskLevel) {
      RiskLevel.low => ('Low risk', Colors.green),
      RiskLevel.moderate => ('Moderate risk', Colors.orange),
      RiskLevel.high => ('High risk', Colors.red),
    };

    return Chip(
      avatar: Icon(Icons.health_and_safety, color: color, size: 18),
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }
}
