class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    this.flag = '🌐',
  });

  // ── Predefined languages ──────────────────────────────────────────────────

  static const english  = Language(code: 'en',  name: 'English',   nativeName: 'English',  flag: '🇬🇧');
  static const hindi    = Language(code: 'hi',  name: 'Hindi',     nativeName: 'हिंदी',    flag: '🇮🇳');
  static const nepali   = Language(code: 'ne',  name: 'Nepali',    nativeName: 'नेपाली',   flag: '🇳🇵');
  static const bhojpuri = Language(code: 'bho', name: 'Bhojpuri',  nativeName: 'भोजपुरी',  flag: '🗣️');
  static const bengali  = Language(code: 'bn',  name: 'Bengali',   nativeName: 'বাংলা',    flag: '🇧🇩');
  static const tamil    = Language(code: 'ta',  name: 'Tamil',     nativeName: 'தமிழ்',    flag: '🇮🇳');
  static const telugu   = Language(code: 'te',  name: 'Telugu',    nativeName: 'తెలుగు',   flag: '🇮🇳');
  static const marathi  = Language(code: 'mr',  name: 'Marathi',   nativeName: 'मराठी',    flag: '🇮🇳');

  static const all = [english, hindi, nepali, bhojpuri, bengali, tamil, telugu, marathi];

  // ── Factory from code ─────────────────────────────────────────────────────

  static Language fromCode(String code) {
    return all.firstWhere(
      (l) => l.code == code,
      orElse: () => english,
    );
  }

  // ── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Language && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Language($code, $name)';
}
