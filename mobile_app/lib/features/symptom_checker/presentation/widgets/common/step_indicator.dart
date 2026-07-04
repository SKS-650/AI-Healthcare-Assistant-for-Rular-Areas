import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class StepIndicator extends StatelessWidget {
  final int activeIndex;
  final int count;

  const StepIndicator({
    super.key,
    required this.activeIndex,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isCompleted = index < activeIndex;
        final isActive = index == activeIndex;

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: isActive || isCompleted
                    ? const LinearGradient(
                        colors: [
                          DesignTokens.primary,
                          DesignTokens.primaryLight,
                        ],
                      )
                    : null,
                color: isActive || isCompleted ? null : DesignTokens.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (index < count - 1) const SizedBox(width: 4),
          ],
        );
      }),
    );
  }
}
