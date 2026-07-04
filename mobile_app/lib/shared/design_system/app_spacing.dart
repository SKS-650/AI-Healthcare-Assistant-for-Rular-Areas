import 'package:flutter/widgets.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static const EdgeInsets screen = EdgeInsets.all(md);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static double responsive(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return xxl;
    if (width >= 600) return xl;
    return md;
  }
}
