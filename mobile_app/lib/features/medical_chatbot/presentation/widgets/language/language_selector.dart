import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/language.dart';

/// Modern card-grid language selector.
/// Replaces the old DropdownButton that crashed when the selected
/// language code was not present in the items list.
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
    // Guard: if selectedLanguage not in list, fall back to first item
    final safeSelected = languages.any((l) => l.code == selectedLanguage.code)
        ? selectedLanguage
        : (languages.isNotEmpty ? languages.first : selectedLanguage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Select your language',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textMuted,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final lang = languages[index];
            final isSelected = lang.code == safeSelected.code;
            return _LanguageCard(
              language:   lang,
              isSelected: isSelected,
              onTap:      () => onChanged(lang),
            );
          },
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.primaryContainer
              : DesignTokens.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? DesignTokens.primary
                : DesignTokens.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              language.flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language.nativeName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? DesignTokens.primaryDark
                          : DesignTokens.textStrong,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    language.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? DesignTokens.primary
                          : DesignTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: DesignTokens.primary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
