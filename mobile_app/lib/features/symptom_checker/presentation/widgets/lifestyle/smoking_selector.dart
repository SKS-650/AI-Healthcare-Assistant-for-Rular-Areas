import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class SmokingSelector extends StatelessWidget {
  final String selectedHabit;
  final ValueChanged<String> onHabitChanged;

  const SmokingSelector({
    super.key,
    required this.selectedHabit,
    required this.onHabitChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = ['Never', 'Occasional', 'Regular (Light)', 'Heavy Smoker'];
    const emojis = ['✅', '🌿', '⚠️', '🚨'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Smoking History',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textStrong)),
        const SizedBox(height: 10),
        ...options.asMap().entries.map((e) {
          final isSelected = selectedHabit == e.value;
          return GestureDetector(
            onTap: () => onHabitChanged(e.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                  Text(emojis[e.key],
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isSelected
                            ? DesignTokens.primaryDark
                            : DesignTokens.textStrong,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: DesignTokens.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
