import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class RiskIndicator extends StatelessWidget {
  final String riskLevel;
  const RiskIndicator({super.key, required this.riskLevel});

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
    final color = _color(riskLevel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_emoji(riskLevel), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            '${riskLevel[0].toUpperCase()}${riskLevel.substring(1)} Risk',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
