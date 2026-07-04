import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  const ConfidenceIndicator({super.key, required this.confidence});

  Color _color(double v) {
    if (v >= 0.7) return DesignTokens.danger;
    if (v >= 0.4) return DesignTokens.warning;
    return DesignTokens.success;
  }

  @override
  Widget build(BuildContext context) {
    final val = confidence.clamp(0.0, 1.0);
    final pct = (val * 100).round();
    final color = _color(val);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Confidence',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: DesignTokens.textStrong)),
            Text('$pct%',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
