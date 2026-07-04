import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class ConfidenceChart extends StatelessWidget {
  final double confidence;
  const ConfidenceChart({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final val = confidence.clamp(0.0, 1.0);
    final pct = (val * 100).round();
    final color = val >= 0.7
        ? DesignTokens.danger
        : val >= 0.4
            ? DesignTokens.warning
            : DesignTokens.success;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: val,
                  strokeWidth: 7,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Confidence',
          style: TextStyle(
            fontSize: 11,
            color: DesignTokens.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
