import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class AlcoholSelector extends StatelessWidget {
  final String selectedConsumption;
  final ValueChanged<String> onConsumptionChanged;

  const AlcoholSelector({
    super.key,
    required this.selectedConsumption,
    required this.onConsumptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tiers = [
      'Never',
      'Rarely / Socially',
      'Moderate (Weekly)',
      'Frequent (Daily)',
    ];
    const emojis = ['✅', '🥤', '🍷', '⚠️'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alcohol Intake',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textStrong)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tiers.asMap().entries.map((e) {
            final isSelected = selectedConsumption == e.value;
            return GestureDetector(
              onTap: () => onConsumptionChanged(e.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            DesignTokens.primary,
                            DesignTokens.primaryDark
                          ],
                        )
                      : null,
                  color: isSelected ? null : DesignTokens.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? DesignTokens.primary
                        : DesignTokens.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                DesignTokens.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emojis[e.key],
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      e.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : DesignTokens.textStrong,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
