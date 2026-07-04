import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppGradients {
  const AppGradients._();

  // Primary purple gradient
  static const LinearGradient purple = LinearGradient(
    colors: DesignTokens.purpleGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Feature gradients
  static const LinearGradient hero = LinearGradient(
    colors: DesignTokens.heroGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient galaxy = LinearGradient(
    colors: DesignTokens.galaxyGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunset = LinearGradient(
    colors: DesignTokens.sunsetGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ocean = LinearGradient(
    colors: DesignTokens.oceanGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient green = LinearGradient(
    colors: DesignTokens.greenGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orange = LinearGradient(
    colors: DesignTokens.orangeGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pink = LinearGradient(
    colors: DesignTokens.pinkGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aqua = LinearGradient(
    colors: DesignTokens.aquaGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blue = LinearGradient(
    colors: DesignTokens.blueGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Medical calm gradient (soft purple → blue)
  static const LinearGradient medical = LinearGradient(
    colors: [Color(0xFF926EFF), Color(0xFF4F94FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Emergency gradient
  static const LinearGradient emergency = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFFF7B3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle card gradient
  static LinearGradient cardSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [DesignTokens.darkSurface, DesignTokens.darkSurfaceMuted]
          : [DesignTokens.surface, DesignTokens.surfaceMuted],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
