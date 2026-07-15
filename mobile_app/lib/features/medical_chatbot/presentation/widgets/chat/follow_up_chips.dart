import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

/// Horizontal scrollable chips of follow-up question suggestions.
class FollowUpChips extends StatelessWidget {
  final List<String> questions;
  final ValueChanged<String> onTap;

  const FollowUpChips({
    super.key,
    required this.questions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 12)),
                SizedBox(width: 5),
                Text(
                  'Follow-up questions',
                  style: TextStyle(
                    fontSize: 11,
                    color: DesignTokens.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: questions
                  .map((q) => _FollowUpChip(text: q, onTap: () => onTap(q)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _FollowUpChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: DesignTokens.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: DesignTokens.primary.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: DesignTokens.primaryDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
