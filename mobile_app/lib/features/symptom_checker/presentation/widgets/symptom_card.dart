import 'package:flutter/material.dart';

import '../../domain/entities/symptom.dart';

class SymptomCard extends StatelessWidget {
  const SymptomCard({
    required this.symptom,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Symptom symptom;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.add_circle_outline,
          color: colorScheme.primary,
        ),
        title: Text(symptom.name),
        subtitle: Text(symptom.description),
        trailing: Text(symptom.category),
      ),
    );
  }
}
