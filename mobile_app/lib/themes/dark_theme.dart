import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/design_system/design_tokens.dart';

class DarkTheme {
  const DarkTheme._();

  static ThemeData get data {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: DesignTokens.primaryLight,
      onPrimary: DesignTokens.primaryDeep,
      primaryContainer: DesignTokens.darkSurfaceHigh,
      onPrimaryContainer: DesignTokens.primaryLight,
      secondary: DesignTokens.blueLight,
      onSecondary: DesignTokens.darkBackground,
      secondaryContainer: DesignTokens.darkSurfaceMuted,
      onSecondaryContainer: DesignTokens.blueLight,
      tertiary: DesignTokens.tealLight,
      onTertiary: DesignTokens.darkBackground,
      tertiaryContainer: DesignTokens.darkSurfaceMuted,
      onTertiaryContainer: DesignTokens.tealLight,
      error: DesignTokens.dangerLight,
      onError: Colors.white,
      errorContainer: const Color(0xFF4A0010),
      onErrorContainer: DesignTokens.dangerLight,
      surface: DesignTokens.darkSurface,
      onSurface: DesignTokens.darkTextStrong,
      surfaceContainerHighest: DesignTokens.darkSurfaceMuted,
      onSurfaceVariant: DesignTokens.darkTextMuted,
      outline: DesignTokens.darkBorder,
      outlineVariant: DesignTokens.darkBorder.withValues(alpha: 0.5),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: DesignTokens.surface,
      onInverseSurface: DesignTokens.textStrong,
      inversePrimary: DesignTokens.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DesignTokens.darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: DesignTokens.darkBackground,
        foregroundColor: DesignTokens.darkTextStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: DesignTokens.darkTextStrong,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: DesignTokens.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          side: const BorderSide(color: DesignTokens.darkBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.primaryLight,
          foregroundColor: DesignTokens.primaryDeep,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DesignTokens.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DesignTokens.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DesignTokens.primaryLight, width: 1.5),
        ),
        labelStyle: const TextStyle(color: DesignTokens.darkTextMuted),
        hintStyle: TextStyle(color: DesignTokens.darkTextMuted.withValues(alpha: 0.6)),
      ),
    );
  }
}
