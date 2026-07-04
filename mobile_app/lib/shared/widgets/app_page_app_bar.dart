import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';

/// Standard app bar used on ALL inner pages.
/// - Proper back arrow icon (never emoji)
/// - Title with optional emoji prefix
/// - Optional action buttons with proper styling
class AppPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? titleEmoji;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final VoidCallback? onBack;

  const AppPageAppBar({
    super.key,
    required this.title,
    this.titleEmoji,
    this.actions,
    this.backgroundColor,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? DesignTokens.background;

    return AppBar(
      backgroundColor: bg,
      foregroundColor: DesignTokens.textStrong,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: DesignTokens.primary.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      // ── Back button — always an icon, never an emoji ────────────────────
      leading: Navigator.canPop(context)
          ? IconButton(
              tooltip: 'Back',
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: DesignTokens.textStrong,
                size: 20,
              ),
            )
          : null,
      // ── Title ───────────────────────────────────────────────────────────
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (titleEmoji != null) ...[
            Text(titleEmoji!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DesignTokens.textStrong,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Standard icon action button for AppBar (settings, refresh, etc.)
class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onTap;
  final Color? color;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: DesignTokens.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DesignTokens.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color ?? DesignTokens.primaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
