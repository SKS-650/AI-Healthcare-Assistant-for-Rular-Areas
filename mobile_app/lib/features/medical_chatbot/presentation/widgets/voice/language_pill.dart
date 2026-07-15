import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

class LanguagePill extends StatelessWidget {
  final String flag;
  final String code;
  final bool isActive;

  const LanguagePill({
    super.key,
    required this.flag,
    required this.code,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? DesignTokens.primary.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? DesignTokens.primary.withValues(alpha: 0.8)
              : Colors.white12,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            code,
            style: TextStyle(
              color:      isActive ? DesignTokens.primaryLight : Colors.white54,
              fontSize:   11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
