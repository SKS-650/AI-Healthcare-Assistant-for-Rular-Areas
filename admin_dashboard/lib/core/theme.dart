import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand palette ─────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary — deep teal
  static const Color primary        = Color(0xFF0EA5A0);
  static const Color primaryLight   = Color(0xFF19C4BF);
  static const Color primaryDark    = Color(0xFF0A7B77);
  static const Color primarySurface = Color(0xFFE6F7F7);

  // Accent — vibrant indigo
  static const Color accent         = Color(0xFF6366F1);
  static const Color accentLight    = Color(0xFF818CF8);
  static const Color accentSurface  = Color(0xFFEEF2FF);

  // Semantic
  static const Color success        = Color(0xFF10B981);
  static const Color successSurface = Color(0xFFD1FAE5);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color error          = Color(0xFFEF4444);
  static const Color errorSurface   = Color(0xFFFEE2E2);
  static const Color info           = Color(0xFF3B82F6);
  static const Color infoSurface    = Color(0xFFDBEAFE);

  // Risk levels
  static const Color riskLow      = Color(0xFF10B981);
  static const Color riskMedium   = Color(0xFFF59E0B);
  static const Color riskHigh     = Color(0xFFEF4444);
  static const Color riskCritical = Color(0xFF7C3AED);

  // Light theme surfaces
  static const Color lightBg         = Color(0xFFF0F4F8);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightSurface2   = Color(0xFFF8FAFC);
  static const Color lightBorder     = Color(0xFFE2E8F0);
  static const Color lightText       = Color(0xFF1E293B);
  static const Color lightTextMuted  = Color(0xFF64748B);
  static const Color lightTextLight  = Color(0xFF94A3B8);

  // Dark theme surfaces
  static const Color darkBg          = Color(0xFF0F172A);
  static const Color darkSurface     = Color(0xFF1E293B);
  static const Color darkSurface2    = Color(0xFF334155);
  static const Color darkBorder      = Color(0xFF334155);
  static const Color darkText        = Color(0xFFF1F5F9);
  static const Color darkTextMuted   = Color(0xFF94A3B8);
  static const Color darkTextLight   = Color(0xFF64748B);

  // Chart colors
  static const List<Color> chartPalette = [
    Color(0xFF0EA5A0),
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
  ];
}

// ── Theme builder ─────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark  => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg       = isDark ? AppColors.darkBg       : AppColors.lightBg;
    final surface  = isDark ? AppColors.darkSurface  : AppColors.lightSurface;
    final border   = isDark ? AppColors.darkBorder   : AppColors.lightBorder;
    final textCol  = isDark ? AppColors.darkText      : AppColors.lightText;
    final mutedCol = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final base = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary:          AppColors.primary,
        onPrimary:        Colors.white,
        primaryContainer: AppColors.primarySurface,
        onPrimaryContainer: AppColors.primaryDark,
        secondary:        AppColors.accent,
        onSecondary:      Colors.white,
        secondaryContainer: AppColors.accentSurface,
        onSecondaryContainer: AppColors.accent,
        error:            AppColors.error,
        onError:          Colors.white,
        surface:          surface,
        onSurface:        textCol,
        surfaceContainerHighest: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        outline:          border,
        outlineVariant:   border.withOpacity(0.5),
      ),
      scaffoldBackgroundColor: bg,
      textTheme: base.copyWith(
        displayLarge:  base.displayLarge?.copyWith(color: textCol, fontWeight: FontWeight.w700, fontSize: 32),
        displayMedium: base.displayMedium?.copyWith(color: textCol, fontWeight: FontWeight.w600, fontSize: 28),
        headlineLarge: base.headlineLarge?.copyWith(color: textCol, fontWeight: FontWeight.w700, fontSize: 24),
        headlineMedium:base.headlineMedium?.copyWith(color: textCol, fontWeight: FontWeight.w600, fontSize: 20),
        headlineSmall: base.headlineSmall?.copyWith(color: textCol, fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge:    base.titleLarge?.copyWith(color: textCol, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium:   base.titleMedium?.copyWith(color: textCol, fontWeight: FontWeight.w500, fontSize: 14),
        titleSmall:    base.titleSmall?.copyWith(color: mutedCol, fontWeight: FontWeight.w500, fontSize: 13),
        bodyLarge:     base.bodyLarge?.copyWith(color: textCol, fontSize: 15),
        bodyMedium:    base.bodyMedium?.copyWith(color: textCol, fontSize: 14),
        bodySmall:     base.bodySmall?.copyWith(color: mutedCol, fontSize: 12),
        labelLarge:    base.labelLarge?.copyWith(color: textCol, fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium:   base.labelMedium?.copyWith(color: mutedCol, fontSize: 12),
        labelSmall:    base.labelSmall?.copyWith(color: mutedCol, fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.inter(color: mutedCol, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: mutedCol, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: border),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textCol,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: textCol, fontSize: 18, fontWeight: FontWeight.w700,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : AppColors.lightText,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: GoogleFonts.inter(fontSize: 14),
      ),
    );
  }
}
