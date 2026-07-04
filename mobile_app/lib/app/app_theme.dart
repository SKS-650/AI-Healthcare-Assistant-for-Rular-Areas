import 'package:flutter/material.dart';

import '../themes/dark_theme.dart';
import '../themes/light_theme.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => LightTheme.data;
  static ThemeData get dark => DarkTheme.data;
}
