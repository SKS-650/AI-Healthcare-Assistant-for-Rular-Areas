import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'app_shadows.dart';

class AppDecoration {
  const AppDecoration._();

  static BoxDecoration card(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: AppRadius.medium,
      border: Border.all(color: colorScheme.outlineVariant),
      boxShadow: AppShadows.subtle(context),
    );
  }

  static BoxDecoration softPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.primaryContainer.withValues(alpha: 0.16),
      borderRadius: AppRadius.large,
      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
    );
  }
}
