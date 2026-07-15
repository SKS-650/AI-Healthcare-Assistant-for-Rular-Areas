import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

/// Shows flag, native name, and English name for each language.
class LanguageSelectorSheet extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onSelect;

  const LanguageSelectorSheet({
    super.key,
    required this.selectedCode,
    required this.onSelect,
  });

  static const _languages = [
    _LangItem('en',  '🇬🇧', 'English',  'English'),
    _LangItem('hi',  '🇮🇳', 'हिंदी',    'Hindi'),
    _LangItem('ne',  '🇳🇵', 'नेपाली',   'Nepali'),
    _LangItem('bho', '🗣️',  'भोजपुरी',  'Bhojpuri'),
    _LangItem('bn',  '🇧🇩', 'বাংলা',    'Bengali'),
    _LangItem('ta',  '🇮🇳', 'தமிழ்',    'Tamil'),
    _LangItem('te',  '🇮🇳', 'తెలుగు',   'Telugu'),
    _LangItem('mr',  '🇮🇳', 'मराठी',    'Marathi'),
    _LangItem('gu',  '🇮🇳', 'ગુજરાતી',  'Gujarati'),
    _LangItem('kn',  '🇮🇳', 'ಕನ್ನಡ',    'Kannada'),
    _LangItem('ml',  '🇮🇳', 'മലയാളം',   'Malayalam'),
    _LangItem('pa',  '🇮🇳', 'ਪੰਜਾਬੀ',   'Punjabi'),
  ];

  /// Open as a bottom sheet and return the selected code.
  static Future<String?> show(
    BuildContext context, {
    required String selectedCode,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LanguageSelectorSheet(
        selectedCode: selectedCode,
        onSelect: (code) => Navigator.of(context).pop(code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize:     0.45,
      maxChildSize:     0.85,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: DesignTokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Text('🌍', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: DesignTokens.border),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: _languages.length,
                itemBuilder: (_, i) {
                  final lang = _languages[i];
                  final isSelected = lang.code == selectedCode;
                  return _LanguageTile(
                    item:       lang,
                    isSelected: isSelected,
                    onTap:      () => onSelect(lang.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final _LangItem item;
  final bool isSelected;
  final VoidCallback onTap;
  const _LanguageTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: isSelected
            ? DesignTokens.primaryContainer
            : Colors.transparent,
        child: Row(
          children: [
            Text(item.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nativeName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? DesignTokens.primaryDark
                          : DesignTokens.textStrong,
                    ),
                  ),
                  Text(
                    item.englishName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: DesignTokens.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LangItem {
  final String code;
  final String flag;
  final String nativeName;
  final String englishName;
  const _LangItem(this.code, this.flag, this.nativeName, this.englishName);
}

/// Compact inline language row used in the chat AppBar / settings.
class LanguageChipRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const LanguageChipRow({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _quickLangs = [
    ('en',  '🇬🇧', 'EN'),
    ('hi',  '🇮🇳', 'HI'),
    ('ne',  '🇳🇵', 'NE'),
    ('bho', '🗣️',  'BHO'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _quickLangs.map((l) {
        final isActive = selected == l.$1;
        return GestureDetector(
          onTap: () => onSelect(l.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isActive
                  ? DesignTokens.primary.withValues(alpha: 0.12)
                  : DesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? DesignTokens.primary : DesignTokens.border,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.$2, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 3),
                Text(
                  l.$3,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? DesignTokens.primaryDark
                        : DesignTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
