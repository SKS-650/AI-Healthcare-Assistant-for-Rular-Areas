import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/prevention.dart';
import 'recommendation_card.dart';

class PreventionCard extends StatelessWidget {
  final Prevention prevention;
  const PreventionCard({super.key, required this.prevention});

  @override
  Widget build(BuildContext context) {
    return RecommendationCard(
      icon: Icons.shield_rounded,
      title: prevention.title,
      description: prevention.description,
      accentColor: DesignTokens.green,
    );
  }
}
