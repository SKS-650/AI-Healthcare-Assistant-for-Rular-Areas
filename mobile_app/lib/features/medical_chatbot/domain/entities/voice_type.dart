/// Voice type configuration for Text-to-Speech.
/// 
/// Defines different voice characteristics including pitch, gender, and voice persona
/// to provide variety in voice output across all supported languages.
enum VoiceType {
  maleLow,
  maleHigh,
  femaleLow,
  femaleHigh,
  femaleSweet,      // Different female voice persona
  femaleEnergetic,  // Different female voice persona
  femaleSoft,       // Different female voice persona
  femaleYoung,      // Different female voice persona
  femaleMature,     // Different female voice persona
  neutral;

  /// Human-readable display name
  String get displayName {
    switch (this) {
      case VoiceType.maleLow:
        return 'Male (Low Pitch)';
      case VoiceType.maleHigh:
        return 'Male (High Pitch)';
      case VoiceType.femaleLow:
        return 'Female (Low Pitch)';
      case VoiceType.femaleHigh:
        return 'Female (High Pitch)';
      case VoiceType.femaleSweet:
        return 'Girl (Sweet Voice)';
      case VoiceType.femaleEnergetic:
        return 'Girl (Energetic Voice)';
      case VoiceType.femaleSoft:
        return 'Girl (Soft Voice)';
      case VoiceType.femaleYoung:
        return 'Girl (Young Voice)';
      case VoiceType.femaleMature:
        return 'Girl (Mature Voice)';
      case VoiceType.neutral:
        return 'Neutral (Default)';
    }
  }

  /// Emoji representation for UI
  String get emoji {
    switch (this) {
      case VoiceType.maleLow:
        return '👨';
      case VoiceType.maleHigh:
        return '🧔';
      case VoiceType.femaleLow:
        return '👩';
      case VoiceType.femaleHigh:
        return '👧';
      case VoiceType.femaleSweet:
        return '🌸';
      case VoiceType.femaleEnergetic:
        return '⚡';
      case VoiceType.femaleSoft:
        return '🌙';
      case VoiceType.femaleYoung:
        return '🎀';
      case VoiceType.femaleMature:
        return '💼';
      case VoiceType.neutral:
        return '🤖';
    }
  }

  /// Pitch value for TTS engine (0.5 - 2.0)
  /// Lower values = deeper voice, Higher values = higher-pitched voice
  double get pitch {
    switch (this) {
      case VoiceType.maleLow:
        return 0.75;
      case VoiceType.maleHigh:
        return 1.0;
      case VoiceType.femaleLow:
        return 1.15;
      case VoiceType.femaleHigh:
        return 1.35;
      case VoiceType.femaleSweet:
        return 1.25;
      case VoiceType.femaleEnergetic:
        return 1.40;
      case VoiceType.femaleSoft:
        return 1.10;
      case VoiceType.femaleYoung:
        return 1.45;
      case VoiceType.femaleMature:
        return 1.05;
      case VoiceType.neutral:
        return 1.0;
    }
  }

  /// Gender for voice selection (used by TTS engine)
  String get gender {
    switch (this) {
      case VoiceType.maleLow:
      case VoiceType.maleHigh:
        return 'male';
      case VoiceType.femaleLow:
      case VoiceType.femaleHigh:
      case VoiceType.femaleSweet:
      case VoiceType.femaleEnergetic:
      case VoiceType.femaleSoft:
      case VoiceType.femaleYoung:
      case VoiceType.femaleMature:
        return 'female';
      case VoiceType.neutral:
        return 'neutral';
    }
  }

  /// Voice quality/persona identifier for TTS engine
  /// This helps differentiate between different voices of the same gender
  String get voiceQuality {
    switch (this) {
      case VoiceType.maleLow:
        return 'deep';
      case VoiceType.maleHigh:
        return 'standard';
      case VoiceType.femaleLow:
        return 'warm';
      case VoiceType.femaleHigh:
        return 'bright';
      case VoiceType.femaleSweet:
        return 'sweet';
      case VoiceType.femaleEnergetic:
        return 'energetic';
      case VoiceType.femaleSoft:
        return 'soft';
      case VoiceType.femaleYoung:
        return 'young';
      case VoiceType.femaleMature:
        return 'mature';
      case VoiceType.neutral:
        return 'neutral';
    }
  }

  /// Preferred voice name patterns for each language
  /// Returns a list of voice name patterns to search for
  /// TTS engines have different voice names on different devices
  List<String> getVoiceNamePatterns(String languageCode) {
    final locale = _getLocaleForLanguage(languageCode);
    final patterns = <String>[];

    switch (this) {
      case VoiceType.maleLow:
        // Deep male voices
        patterns.addAll([
          '$locale-male-1',
          '$locale-male-low',
          'male-$locale-1',
          'male-deep',
          'male-1',
        ]);
        break;

      case VoiceType.maleHigh:
        // Standard male voices
        patterns.addAll([
          '$locale-male-2',
          '$locale-male',
          'male-$locale-2',
          'male-standard',
          'male-2',
        ]);
        break;

      case VoiceType.femaleLow:
        // Warm female voices (lower pitch female)
        patterns.addAll([
          '$locale-female-1',
          '$locale-female-low',
          'female-$locale-1',
          'female-warm',
          'female-1',
        ]);
        break;

      case VoiceType.femaleHigh:
        // Bright female voices
        patterns.addAll([
          '$locale-female-2',
          '$locale-female-high',
          'female-$locale-2',
          'female-bright',
          'female-2',
        ]);
        break;

      case VoiceType.femaleSweet:
        // Sweet female voices (persona 3)
        patterns.addAll([
          '$locale-female-3',
          'female-$locale-3',
          'female-sweet',
          'female-3',
        ]);
        break;

      case VoiceType.femaleEnergetic:
        // Energetic female voices (persona 4)
        patterns.addAll([
          '$locale-female-4',
          'female-$locale-4',
          'female-energetic',
          'female-4',
        ]);
        break;

      case VoiceType.femaleSoft:
        // Soft female voices (persona 5)
        patterns.addAll([
          '$locale-female-5',
          'female-$locale-5',
          'female-soft',
          'female-5',
        ]);
        break;

      case VoiceType.femaleYoung:
        // Young female voices (persona 6)
        patterns.addAll([
          '$locale-female-6',
          'female-$locale-6',
          'female-young',
          'female-6',
        ]);
        break;

      case VoiceType.femaleMature:
        // Mature female voices (persona 7)
        patterns.addAll([
          '$locale-female-7',
          'female-$locale-7',
          'female-mature',
          'female-7',
        ]);
        break;

      case VoiceType.neutral:
        // Neutral voices
        patterns.addAll([
          '$locale-neutral',
          'neutral-$locale',
          locale,
        ]);
        break;
    }

    // Add generic fallbacks based on gender
    if (gender == 'male') {
      patterns.addAll(['male', '$locale-male']);
    } else if (gender == 'female') {
      patterns.addAll(['female', '$locale-female']);
    }

    return patterns;
  }

  /// Helper to get locale string for language code
  String _getLocaleForLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'en-IN';
      case 'hi':
        return 'hi-IN';
      case 'ne':
        return 'ne-NP';
      case 'bho':
        return 'hi-IN'; // Bhojpuri uses Hindi locale
      default:
        return 'en-IN';
    }
  }

  /// Language-specific pitch adjustment
  /// Some languages sound better with slight pitch modifications
  double getPitchForLanguage(String languageCode) {
    final basePitch = pitch;
    
    // Hindi and Bhojpuri sound more natural with slightly higher pitch
    if (languageCode == 'hi' || languageCode == 'bho') {
      return (basePitch * 1.05).clamp(0.5, 2.0);
    }
    
    // Nepali sounds good with moderate pitch
    if (languageCode == 'ne') {
      return (basePitch * 1.02).clamp(0.5, 2.0);
    }
    
    // English uses base pitch
    return basePitch;
  }

  /// Speech rate modifier based on voice type
  /// Some voice types sound better at different speeds
  double get speechRateModifier {
    switch (this) {
      case VoiceType.femaleEnergetic:
        return 1.05; // Slightly faster for energetic voice
      case VoiceType.femaleSoft:
        return 0.95; // Slightly slower for soft voice
      case VoiceType.femaleMature:
        return 0.98; // Slightly slower for mature voice
      default:
        return 1.0; // Normal speed
    }
  }

  /// Description for the voice type
  String get description {
    switch (this) {
      case VoiceType.maleLow:
        return 'Deep, warm male voice';
      case VoiceType.maleHigh:
        return 'Clear, standard male voice';
      case VoiceType.femaleLow:
        return 'Smooth, warm female voice';
      case VoiceType.femaleHigh:
        return 'Bright, clear female voice';
      case VoiceType.femaleSweet:
        return 'Sweet, gentle girl voice';
      case VoiceType.femaleEnergetic:
        return 'Energetic, lively girl voice';
      case VoiceType.femaleSoft:
        return 'Soft, calm girl voice';
      case VoiceType.femaleYoung:
        return 'Young, playful girl voice';
      case VoiceType.femaleMature:
        return 'Mature, professional girl voice';
      case VoiceType.neutral:
        return 'Balanced, natural voice';
    }
  }

  /// Convert from string code
  static VoiceType fromCode(String code) {
    switch (code) {
      case 'maleLow':
        return VoiceType.maleLow;
      case 'maleHigh':
        return VoiceType.maleHigh;
      case 'femaleLow':
        return VoiceType.femaleLow;
      case 'femaleHigh':
        return VoiceType.femaleHigh;
      case 'femaleSweet':
        return VoiceType.femaleSweet;
      case 'femaleEnergetic':
        return VoiceType.femaleEnergetic;
      case 'femaleSoft':
        return VoiceType.femaleSoft;
      case 'femaleYoung':
        return VoiceType.femaleYoung;
      case 'femaleMature':
        return VoiceType.femaleMature;
      case 'neutral':
        return VoiceType.neutral;
      default:
        return VoiceType.neutral;
    }
  }

  /// Convert to string code for serialization
  String get code {
    return name;
  }
}
