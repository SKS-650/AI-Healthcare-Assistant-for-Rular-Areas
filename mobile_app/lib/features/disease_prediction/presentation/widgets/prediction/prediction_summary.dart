import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/prediction_result.dart';
import 'confidence_indicator.dart';
import 'risk_indicator.dart';

class PredictionSummary extends StatelessWidget {
  final PredictionResult result;
  const PredictionSummary({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        border: Border.all(color: DesignTokens.border),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.disease.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: DesignTokens.textStrong,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              RiskIndicator(riskLevel: result.riskLevel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.disease.shortDescription,
            style: const TextStyle(
              color: DesignTokens.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ConfidenceIndicator(confidence: result.confidence),
        ],
      ),
    );
  }
}
