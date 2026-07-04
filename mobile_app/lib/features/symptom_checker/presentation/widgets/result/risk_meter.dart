import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class RiskMeter extends StatelessWidget {
  final String riskLevel;
  final double confidenceScore;

  const RiskMeter({
    super.key,
    required this.riskLevel,
    required this.confidenceScore,
  });

  Color _color(String r) {
    switch (r.toLowerCase()) {
      case 'high': return DesignTokens.danger;
      case 'medium':
      case 'moderate': return DesignTokens.warning;
      case 'critical': return const Color(0xFF7C0000);
      default: return DesignTokens.success;
    }
  }

  String _emoji(String r) {
    switch (r.toLowerCase()) {
      case 'high': return '🔴';
      case 'medium':
      case 'moderate': return '⚠️';
      case 'critical': return '🚨';
      default: return '✅';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(riskLevel);
    final val = confidenceScore.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Risk Assessment',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_emoji(riskLevel),
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      '${riskLevel[0].toUpperCase()}${riskLevel.substring(1)} Risk',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 9,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Confidence',
                  style: TextStyle(
                      fontSize: 12, color: DesignTokens.textMuted)),
              Text('${(val * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
