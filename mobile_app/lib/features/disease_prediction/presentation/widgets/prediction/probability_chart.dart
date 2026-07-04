import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class ProbabilityChart extends StatelessWidget {
  final Map<String, double> probabilities;
  const ProbabilityChart({super.key, required this.probabilities});

  static const _colors = [
    DesignTokens.primary,
    DesignTokens.blue,
    DesignTokens.green,
    DesignTokens.orange,
    DesignTokens.teal,
    DesignTokens.pink,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.asMap().entries.map((e) {
        final idx = e.key;
        final entry = e.value;
        final val = entry.value.clamp(0.0, 1.0);
        final pct = (val * 100).round();
        final color = _colors[idx % _colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textStrong,
                      ),
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: val,
                  minHeight: 7,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
