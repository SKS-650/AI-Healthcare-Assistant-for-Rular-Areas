import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/design_system/design_tokens.dart';

class LightTheme {
  const LightTheme._();

  static ThemeData get data {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: DesignTokens.primary,
      onPrimary: Colors.white,
      primaryContainer: DesignTokens.primaryContainer,
      onPrimaryContainer: DesignTokens.primaryDark,
      secondary: DesignTokens.blue,
      onSecondary: Colors.white,
      secondaryContainer: DesignTokens.blueContainer,
      onSecondaryContainer: DesignTokens.secondaryDark,
      tertiary: DesignTokens.teal,
      onTertiary: Colors.white,
      tertiaryContainer: DesignTokens.tealContainer,
      onTertiaryContainer: DesignTokens.teal,
      error: DesignTokens.danger,
      onError: Colors.white,
      errorContainer: DesignTokens.dangerContainer,
      onErrorContainer: DesignTokens.danger,
      surface: DesignTokens.surface,
      onSurface: DesignTokens.textStrong,
      surfaceContainerHighest: DesignTokens.surfaceMuted,
      onSurfaceVariant: DesignTokens.textMuted,
      outline: DesignTokens.border,
      outlineVariant: DesignTokens.borderMuted,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: DesignTokens.darkSurface,
      onInverseSurface: DesignTokens.darkTextStrong,
      inversePrimary: DesignTokens.primaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DesignTokens.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: DesignTokens.background,
        foregroundColor: DesignTokens.textStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: DesignTokens.textStrong,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: DesignTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          side: const BorderSide(color: DesignTokens.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primary,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: DesignTokens.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.primary,
          minimumSize: const Size(0, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DesignTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DesignTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DesignTokens.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DesignTokens.danger),
        ),
        labelStyle: const TextStyle(color: DesignTokens.textMuted),
        hintStyle: const TextStyle(color: DesignTokens.textSubtle),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.surfaceMuted,
        selectedColor: DesignTokens.primaryContainer,
        side: const BorderSide(color: DesignTokens.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DesignTokens.textStrong,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DesignTokens.border,
        thickness: 1,
        space: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: DesignTokens.primary,
        inactiveTrackColor: DesignTokens.primaryContainer,
        thumbColor: DesignTokens.primary,
        overlayColor: DesignTokens.primary.withValues(alpha: 0.12),
        trackHeight: 4,
      ),
    );
  }
}
