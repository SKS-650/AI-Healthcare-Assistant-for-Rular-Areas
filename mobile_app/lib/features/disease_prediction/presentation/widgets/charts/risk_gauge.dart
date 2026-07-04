import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class RiskGauge extends StatelessWidget {
  final String riskLevel;
  const RiskGauge({super.key, required this.riskLevel});

  double _value(String r) {
    switch (r.toLowerCase()) {
      case 'low': return 0.2;
      case 'medium':
      case 'moderate': return 0.5;
      case 'high': return 0.75;
      case 'critical': return 1.0;
      default: return 0.3;
    }
  }

  Color _color(String r) {
    switch (r.toLowerCase()) {
      case 'low': return DesignTokens.success;
      case 'medium':
      case 'moderate': return DesignTokens.warning;
      case 'high': return DesignTokens.orange;
      case 'critical': return DesignTokens.danger;
      default: return DesignTokens.primary;
    }
  }

  String _emoji(String r) {
    switch (r.toLowerCase()) {
      case 'low': return '✅';
      case 'medium':
      case 'moderate': return '⚠️';
      case 'high': return '🔴';
      case 'critical': return '🚨';
      default: return '📊';
    }
  }

  @override
  Widget build(BuildContext context) {
    final val = _value(riskLevel);
    final color = _color(riskLevel);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_emoji(riskLevel), style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 7,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${riskLevel[0].toUpperCase()}${riskLevel.substring(1)} Risk',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
