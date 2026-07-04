import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class ExerciseSelector extends StatelessWidget {
  final String selectedFrequency;
  final ValueChanged<String> onFrequencyChanged;

  const ExerciseSelector({
    super.key,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    const intensities = [
      ('Sedentary', '🛋️', 'Little to no physical activity'),
      ('Light', '🚶', '1–2 days of light activity/week'),
      ('Medium', '🏃', '3–5 days of moderate exercise/week'),
      ('Active', '🏋️', '6–7 days of heavy exercise/week'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Exercise Frequency',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textStrong)),
        const SizedBox(height: 10),
        ...intensities.map((item) {
          final isSelected = selectedFrequency == item.$1;
          return GestureDetector(
            onTap: () => onFrequencyChanged(item.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isSelected
                    ? DesignTokens.primaryContainer
                    : DesignTokens.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? DesignTokens.primary.withValues(alpha: 0.5)
                      : DesignTokens.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(item.$2,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isSelected
                                  ? DesignTokens.primaryDark
                                  : DesignTokens.textStrong,
                            )),
                        Text(item.$3,
                            style: const TextStyle(
                                color: DesignTokens.textMuted,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded,
                        color: DesignTokens.primary, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
