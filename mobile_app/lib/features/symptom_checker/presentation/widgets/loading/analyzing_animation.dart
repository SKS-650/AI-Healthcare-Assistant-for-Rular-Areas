import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class AnalyzingAnimation extends StatefulWidget {
  const AnalyzingAnimation({super.key});

  @override
  State<AnalyzingAnimation> createState() => _AnalyzingAnimationState();
}

class _AnalyzingAnimationState extends State<AnalyzingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignTokens.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignTokens.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DesignTokens.surface,
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: DesignTokens.primary,
              ),
            ),
          ),
          const Icon(Icons.analytics_outlined,
              size: 28, color: DesignTokens.primary),
        ],
      ),
    );
  }
}
