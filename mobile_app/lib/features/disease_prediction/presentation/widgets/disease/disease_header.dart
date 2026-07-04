import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/disease.dart';

class DiseaseHeader extends StatelessWidget {
  final Disease disease;
  const DiseaseHeader({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          disease.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: DesignTokens.textStrong,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          disease.shortDescription,
          style: const TextStyle(
            color: DesignTokens.textMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
