import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/disease.dart';

class DiseaseSymptoms extends StatelessWidget {
  final Disease disease;
  const DiseaseSymptoms({super.key, required this.disease});

  static const _colors = [
    DesignTokens.primary,
    DesignTokens.blue,
    DesignTokens.orange,
    DesignTokens.teal,
    DesignTokens.pink,
    DesignTokens.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: disease.symptoms.asMap().entries.map((e) {
        final color = _colors[e.key % _colors.length];
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 6, color: color),
              const SizedBox(width: 6),
              Text(
                e.value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
