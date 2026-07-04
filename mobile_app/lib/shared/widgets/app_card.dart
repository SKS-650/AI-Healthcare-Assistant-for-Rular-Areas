import 'package:flutter/material.dart';

import '../design_system/app_animations.dart';
import '../design_system/app_decoration.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final decoration = AppDecoration.card(context);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: AppAnimations.fast,
      curve: AppAnimations.standard,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.standard,
        margin: widget.margin,
        decoration: decoration.copyWith(
          color: widget.backgroundColor ?? decoration.color,
          borderRadius: widget.borderRadius ?? AppRadius.medium,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: widget.borderRadius ?? AppRadius.medium,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
