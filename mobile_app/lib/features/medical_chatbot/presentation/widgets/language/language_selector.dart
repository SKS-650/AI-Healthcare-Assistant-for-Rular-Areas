// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../domain/entities/language.dart';

class LanguageSelector extends StatelessWidget {
  final Language selectedLanguage;
  final List<Language> languages;
  final ValueChanged<Language> onChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedLanguage.code,
      decoration: const InputDecoration(labelText: 'Language'),
      items: languages
          .map(
            (language) => DropdownMenuItem(
              value: language.code,
              child: Text('${language.name} (${language.nativeName})'),
            ),
          )
          .toList(),
      onChanged: (code) {
        final selected = languages.firstWhere(
          (language) => language.code == code,
        );
        onChanged(selected);
      },
    );
  }
}
