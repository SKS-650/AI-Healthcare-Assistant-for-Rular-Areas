import 'package:flutter/material.dart';

import '../../../domain/entities/suggestion.dart';
import 'suggestion_list.dart';

class QuickQuestions extends StatelessWidget {
  final List<Suggestion> suggestions;
  final ValueChanged<String> onSelected;

  const QuickQuestions({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return SuggestionList(suggestions: suggestions, onSelected: onSelected);
  }
}
