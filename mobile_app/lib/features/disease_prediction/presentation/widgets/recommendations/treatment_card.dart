import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/treatment.dart';
import 'recommendation_card.dart';

class TreatmentCard extends StatelessWidget {
  final Treatment treatment;
  const TreatmentCard({super.key, required this.treatment});

  @override
  Widget build(BuildContext context) {
    return RecommendationCard(
      icon: Icons.healing_rounded,
      title: '${treatment.title}  •  ${treatment.duration}',
      description: treatment.description,
      accentColor: DesignTokens.teal,
    );
  }
}
