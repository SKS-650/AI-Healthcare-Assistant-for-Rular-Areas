import 'package:flutter/material.dart';

import '../../../domain/entities/suggestion.dart';
import 'suggestion_chip.dart';

class SuggestionList extends StatelessWidget {
  final List<Suggestion> suggestions;
  final ValueChanged<String> onSelected;

  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (final suggestion in suggestions) ...[
            SuggestionChipWidget(
              suggestion: suggestion,
              onSelected: onSelected,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
