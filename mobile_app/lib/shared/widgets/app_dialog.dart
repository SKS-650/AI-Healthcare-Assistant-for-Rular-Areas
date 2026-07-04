import 'package:flutter/material.dart';

import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final AppButtonVariant primaryVariant;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.primaryLabel = 'OK',
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
    this.primaryVariant = AppButtonVariant.filled,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    String primaryLabel = 'OK',
    String? secondaryLabel,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    AppButtonVariant primaryVariant = AppButtonVariant.filled,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        icon: icon,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        primaryVariant: primaryVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
      icon: icon == null ? null : Icon(icon, size: 34),
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: [
        if (secondaryLabel != null)
          TextButton(
            onPressed: onSecondary ?? () => Navigator.of(context).pop(false),
            child: Text(secondaryLabel!),
          ),
        AppButton(
          label: primaryLabel,
          onPressed: onPrimary ?? () => Navigator.of(context).pop(true),
          variant: primaryVariant,
        ),
      ],
    );
  }
}
