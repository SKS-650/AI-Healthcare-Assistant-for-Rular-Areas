import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

/// Standard page wrapper with title, optional actions, and scrollable content.
class PageWrapper extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;
  final bool scrollable;
  final EdgeInsets? padding;

  const PageWrapper({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.child,
    this.scrollable = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700))
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.05),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(subtitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted))
                            .animate()
                            .fadeIn(delay: 100.ms),
                      ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ── Body ──────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding:
                padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: child,
          ),
        ),
      ],
    );

    return scrollable
        ? SingleChildScrollView(child: content)
        : content;
  }
}

/// A section header inside a page
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ],
        ),
      );
}
