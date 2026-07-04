import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/disease.dart';

class DiseaseInformation extends StatelessWidget {
  final Disease disease;
  const DiseaseInformation({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Text(
      disease.overview,
      style: const TextStyle(
        color: DesignTokens.textMuted,
        fontSize: 14,
        height: 1.65,
      ),
    );
  }
}
