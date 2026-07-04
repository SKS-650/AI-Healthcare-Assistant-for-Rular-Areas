import 'package:flutter/material.dart';

class DesignTokens {
  const DesignTokens._();

  // ── PRIMARY — Light Purple #926eff ────────────────────────────────────────
  static const Color primary        = Color(0xFF926EFF); // main purple
  static const Color primaryLight   = Color(0xFFB89EFF); // lighter purple
  static const Color primaryDark    = Color(0xFF6B47E8); // deeper purple
  static const Color primaryDeep    = Color(0xFF4A2FC4); // darkest purple
  static const Color primaryContainer = Color(0xFFF0EBFF); // very light purple bg
  static const Color primaryMuted   = Color(0xFFE8E0FF); // subtle purple tint

  // ── ACCENT PALETTE — Vibrant Multi-Color System ───────────────────────────
  // Blue
  static const Color blue           = Color(0xFF4F94FF);
  static const Color blueLight      = Color(0xFF82B4FF);
  static const Color blueContainer  = Color(0xFFE8F1FF);

  // Green
  static const Color green          = Color(0xFF2ECC8B);
  static const Color greenLight     = Color(0xFF6EE8B5);
  static const Color greenContainer = Color(0xFFE4FBF0);

  // Yellow / Amber
  static const Color yellow         = Color(0xFFFFB829);
  static const Color yellowLight    = Color(0xFFFFD166);
  static const Color yellowContainer= Color(0xFFFFF8E6);

  // Orange
  static const Color orange         = Color(0xFFFF7B3D);
  static const Color orangeLight    = Color(0xFFFFAA7A);
  static const Color orangeContainer= Color(0xFFFFF0E8);

  // Pink / Rose
  static const Color pink           = Color(0xFFFF5E9E);
  static const Color pinkLight      = Color(0xFFFF94C0);
  static const Color pinkContainer  = Color(0xFFFFEAF3);

  // Aqua / Cyan
  static const Color aqua           = Color(0xFF18C8C8);
  static const Color aquaLight      = Color(0xFF5CDEDE);
  static const Color aquaContainer  = Color(0xFFE4FAFA);

  // Teal
  static const Color teal           = Color(0xFF1BB8A3);
  static const Color tealLight      = Color(0xFF57D4C4);
  static const Color tealContainer  = Color(0xFFE3F8F5);

  // Brown / Warm
  static const Color brown          = Color(0xFFBF8B5E);
  static const Color brownLight     = Color(0xFFD9AA80);
  static const Color brownContainer = Color(0xFFF9EDE0);

  // Indigo
  static const Color indigo         = Color(0xFF5F6FFF);
  static const Color indigoLight    = Color(0xFF8F9CFF);
  static const Color indigoContainer= Color(0xFFEEEFFF);

  // Lime
  static const Color lime           = Color(0xFF8CCA2B);
  static const Color limeContainer  = Color(0xFFF2FAE3);

  // ── SEMANTIC ──────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF2ECC8B);
  static const Color successLight   = Color(0xFF6EE8B5);
  static const Color successContainer = Color(0xFFE4FBF0);

  static const Color warning        = Color(0xFFFFB829);
  static const Color warningLight   = Color(0xFFFFD166);
  static const Color warningContainer = Color(0xFFFFF8E6);

  static const Color danger         = Color(0xFFFF4757);
  static const Color dangerLight    = Color(0xFFFF7F8A);
  static const Color dangerContainer= Color(0xFFFFECED);

  static const Color info           = Color(0xFF4F94FF);
  static const Color infoContainer  = Color(0xFFE8F1FF);

  // ── NEUTRAL / SURFACE ─────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF8F6FF); // very subtle purple bg
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceMuted   = Color(0xFFF4F2FF); // light purple-tinted
  static const Color surfaceHigh    = Color(0xFFEDE8FF);
  static const Color textStrong     = Color(0xFF1A1035); // near-black with purple
  static const Color textMuted      = Color(0xFF6B6289); // muted purple-grey
  static const Color textSubtle     = Color(0xFF9E98B8); // lighter
  static const Color border         = Color(0xFFE8E2F8); // purple-tinted border
  static const Color borderMuted    = Color(0xFFF2EFFE);

  // ── DARK MODE ─────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0A1E);
  static const Color darkSurface    = Color(0xFF1A1335);
  static const Color darkSurfaceMuted= Color(0xFF241B44);
  static const Color darkSurfaceHigh = Color(0xFF2E2456);
  static const Color darkTextStrong = Color(0xFFF3F0FF);
  static const Color darkTextMuted  = Color(0xFFB8AAFF);
  static const Color darkBorder     = Color(0xFF3D2F72);

  // ── GRADIENTS (as color lists) ────────────────────────────────────────────
  // Used via AppGradients class
  static const List<Color> purpleGradient  = [Color(0xFF926EFF), Color(0xFF6B47E8)];
  static const List<Color> blueGradient    = [Color(0xFF4F94FF), Color(0xFF2563EB)];
  static const List<Color> greenGradient   = [Color(0xFF2ECC8B), Color(0xFF16A34A)];
  static const List<Color> orangeGradient  = [Color(0xFFFF7B3D), Color(0xFFE55A1A)];
  static const List<Color> pinkGradient    = [Color(0xFFFF5E9E), Color(0xFFE11D68)];
  static const List<Color> aquaGradient    = [Color(0xFF18C8C8), Color(0xFF0B9B9B)];
  static const List<Color> sunsetGradient  = [Color(0xFFFF7B3D), Color(0xFFFF5E9E)];
  static const List<Color> oceanGradient   = [Color(0xFF4F94FF), Color(0xFF18C8C8)];
  static const List<Color> galaxyGradient  = [Color(0xFF926EFF), Color(0xFFFF5E9E)];
  static const List<Color> heroGradient    = [Color(0xFF6B47E8), Color(0xFF4F94FF)];

  // ── SIZING ────────────────────────────────────────────────────────────────
  static const double minTouchTarget = 48;
  static const double maxContentWidth = 720;
  static const double cardRadius = 20;
  static const double pillRadius = 999;

  // ── COMPAT ALIASES (keeps old references working) ─────────────────────────
  static const Color secondary           = blue;
  static const Color secondaryLight      = blueLight;
  static const Color secondaryDark       = Color(0xFF2A6FE0);
  static const Color secondaryContainer  = blueContainer;
  static const Color emerald             = green;
  static const Color emeraldLight        = greenLight;
  static const Color emeraldContainer    = greenContainer;
  static const Color sky                 = Color(0xFF38BDF8);
  static const Color skyLight            = Color(0xFF7DD3FC);
  static const Color skyContainer        = Color(0xFFE0F2FE);
  static const Color violet              = Color(0xFF8B5CF6);
  static const Color violetContainer     = Color(0xFFEDE9FE);
  static const Color rose                = Color(0xFFE11D48);
  static const Color roseContainer       = Color(0xFFFFE4E6);
}
