import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/prediction.dart';

class RecentPredictionsList extends StatelessWidget {
  final List<Prediction> predictions;
  const RecentPredictionsList({super.key, required this.predictions});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: predictions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) =>
          _PredictionCard(prediction: predictions[i]),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final Prediction prediction;
  const _PredictionCard({required this.prediction});

  Color _confidenceColor(double c) {
    if (c >= 0.7) return DesignTokens.danger;
    if (c >= 0.4) return DesignTokens.warning;
    return DesignTokens.success;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (prediction.confidence * 100).toStringAsFixed(0);
    final col = _confidenceColor(prediction.confidence);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: DesignTokens.primaryContainer,
                borderRadius: BorderRadius.circular(12)),
            child: const Center(
                child: Text('🧬', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prediction.diseaseName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: DesignTokens.textStrong)),
                const SizedBox(height: 3),
                Text(
                    '${prediction.date.day}/${prediction.date.month}/${prediction.date.year}',
                    style: const TextStyle(
                        color: DesignTokens.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: col.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Text('$pct%',
                style: TextStyle(
                    color: col,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
