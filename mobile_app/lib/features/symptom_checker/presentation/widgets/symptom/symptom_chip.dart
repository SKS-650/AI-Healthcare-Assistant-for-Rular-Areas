import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/symptom.dart';

class SymptomChip extends StatelessWidget {
  final Symptom symptom;
  final bool isSelected;
  final VoidCallback onSelected;

  const SymptomChip({
    super.key,
    required this.symptom,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.primaryContainer
              : DesignTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? DesignTokens.primary.withValues(alpha: 0.5)
                : DesignTokens.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check_rounded,
                    size: 13, color: DesignTokens.primary),
              ),
            Text(
              symptom.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? DesignTokens.primaryDark
                    : DesignTokens.textStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
