import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Premium animated page indicator — works on both light and dark surfaces
// ─────────────────────────────────────────────────────────────────────────────

/// Classic pill indicator — used on light (white card) surfaces.
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
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? DesignTokens.primary : DesignTokens.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Premium glowing indicator — used on dark gradient (onboarding) surfaces.
/// Active dot expands, glows, and shows the accent color.
class PremiumOnboardingIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const PremiumOnboardingIndicator({
    super.key,
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        final isPast = i < current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? activeColor
                : isPast
                    ? activeColor.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
