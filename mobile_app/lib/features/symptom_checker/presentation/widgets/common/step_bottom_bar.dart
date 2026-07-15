import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

/// Reusable bottom action bar for symptom checker steps.
class StepBottomBar extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const StepBottomBar({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: DesignTokens.background,
        border: const Border(
          top: BorderSide(color: DesignTokens.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: enabled ? onTap : null,
          style: FilledButton.styleFrom(
            backgroundColor: enabled ? DesignTokens.primary : DesignTokens.border,
            foregroundColor: enabled ? Colors.white : DesignTokens.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
