import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/medicine.dart';
import 'recommendation_card.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const MedicineCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return RecommendationCard(
      icon: Icons.medication_rounded,
      title: '${medicine.name}  •  ${medicine.dosage}',
      description: '${medicine.timing}. ${medicine.note}',
      accentColor: DesignTokens.blue,
    );
  }
}
