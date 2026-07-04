import 'package:flutter/material.dart';

import '../design_system/app_gradients.dart';
import '../design_system/app_radius.dart';
import '../design_system/design_tokens.dart';

enum AppButtonVariant { filled, tonal, outlined, text, gradient, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.variant = AppButtonVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton.icon(
        onPressed: _effectiveOnPressed,
        icon: _icon,
        label: _label,
      ),
      AppButtonVariant.tonal => FilledButton.tonalIcon(
        onPressed: _effectiveOnPressed,
        icon: _icon,
        label: _label,
      ),
      AppButtonVariant.outlined => OutlinedButton.icon(
        onPressed: _effectiveOnPressed,
        icon: _icon,
        label: _label,
      ),
      AppButtonVariant.text => TextButton.icon(
        onPressed: _effectiveOnPressed,
        icon: _icon,
        label: _label,
      ),
      AppButtonVariant.danger => FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.danger,
          foregroundColor: Colors.white,
        ),
        onPressed: _effectiveOnPressed,
        icon: _icon,
        label: _label,
      ),
      AppButtonVariant.gradient => _GradientButton(
        onPressed: _effectiveOnPressed,
        icon: _icon,
        label: _label,
      ),
    };

    final constrained = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DesignTokens.minTouchTarget),
      child: button,
    );

    if (expand) return SizedBox(width: double.infinity, child: constrained);
    return constrained;
  }

  VoidCallback? get _effectiveOnPressed {
    if (isLoading) return null;
    return onPressed;
  }

  Widget get _icon {
    if (isLoading) {
      return const SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Icon(icon ?? Icons.arrow_forward_rounded);
  }

  Widget get _label => Text(label, overflow: TextOverflow.ellipsis);
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;

  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppGradients.medical,
        color: onPressed == null
            ? Theme.of(context).disabledColor.withValues(alpha: 0.12)
            : null,
        borderRadius: AppRadius.circular,
      ),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        icon: icon,
        label: label,
      ),
    );
  }
}
