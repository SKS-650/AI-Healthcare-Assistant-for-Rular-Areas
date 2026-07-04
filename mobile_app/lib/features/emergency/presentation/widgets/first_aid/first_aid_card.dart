import 'package:flutter/material.dart';

import '../../../domain/entities/first_aid.dart';
import 'first_aid_category.dart';
import 'first_aid_step.dart';

class FirstAidCard extends StatelessWidget {
  final FirstAid guide;

  const FirstAidCard({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        leading: const Icon(Icons.health_and_safety_outlined),
        title: Text(guide.title),
        subtitle: Text(guide.summary),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FirstAidCategory(category: guide.category),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < guide.steps.length; i++)
            FirstAidStep(index: i + 1, text: guide.steps[i]),
        ],
      ),
    );
  }
}
