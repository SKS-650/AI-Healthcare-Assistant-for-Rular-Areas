import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

class OnboardingIndicator extends StatelessWidget {
  final int count;
  final int current;

  const OnboardingIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? DesignTokens.primary
                : DesignTokens.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
