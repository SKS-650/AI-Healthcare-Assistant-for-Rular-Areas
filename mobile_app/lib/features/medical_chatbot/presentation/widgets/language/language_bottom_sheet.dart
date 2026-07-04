// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../domain/entities/language.dart';

class LanguageBottomSheet extends StatelessWidget {
  final Language selectedLanguage;
  final List<Language> languages;
  final ValueChanged<Language> onSelected;

  const LanguageBottomSheet({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final language in languages)
            RadioListTile<String>(
              value: language.code,
              groupValue: selectedLanguage.code,
              title: Text(language.name),
              subtitle: Text(language.nativeName),
              onChanged: (_) {
                onSelected(language);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
