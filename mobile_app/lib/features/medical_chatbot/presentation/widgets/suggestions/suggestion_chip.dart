import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/suggestion.dart';

class SuggestionChipWidget extends StatelessWidget {
  final Suggestion suggestion;
  final ValueChanged<String> onSelected;

  const SuggestionChipWidget({
    super.key,
    required this.suggestion,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(suggestion.text),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: DesignTokens.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: DesignTokens.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.primary.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💡', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              suggestion.text,
              style: const TextStyle(
                color: DesignTokens.primaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
