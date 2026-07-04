import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/prediction_result.dart';

class HistoryCard extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback? onTap;

  const HistoryCard({super.key, required this.result, this.onTap});

  Color _riskColor(String r) {
    switch (r.toLowerCase()) {
      case 'low': return DesignTokens.success;
      case 'medium':
      case 'moderate': return DesignTokens.warning;
      case 'high': return DesignTokens.orange;
      case 'critical': return DesignTokens.danger;
      default: return DesignTokens.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = _riskColor(result.riskLevel);
    final pct = (result.confidence * 100).toStringAsFixed(0);
    final date = result.createdAt;
    final dateStr =
        '${date.day}/${date.month}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rc.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: rc.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: rc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Center(
                      child: Text('🧬', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.disease.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: DesignTokens.textStrong,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 11, color: DesignTokens.textSubtle),
                          const SizedBox(width: 4),
                          Text(dateStr,
                              style: const TextStyle(
                                  color: DesignTokens.textSubtle,
                                  fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: rc.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$pct%',
                        style: TextStyle(
                          color: rc,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: rc.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${result.riskLevel[0].toUpperCase()}${result.riskLevel.substring(1)}',
                        style: TextStyle(
                          color: rc,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
