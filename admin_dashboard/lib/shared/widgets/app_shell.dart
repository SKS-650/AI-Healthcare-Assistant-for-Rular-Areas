import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../features/authentication/auth_provider.dart';
import 'sidebar.dart';
import 'top_bar.dart';

// ── Sidebar collapsed state ───────────────────────────────────────────────────
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < AppConstants.mobileBreakpoint;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ───────────────────────────────────────────────────────
          if (!isMobile)
            AnimatedContainer(
              duration: AppConstants.animNormal,
              width: collapsed
                  ? AppConstants.sidebarWidthCollapsed
                  : AppConstants.sidebarWidthExpanded,
              child: const Sidebar(),
            ),

          // ── Main content ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                TopBar(
                  onMenuTap: isMobile
                      ? null
                      : () => ref
                          .read(sidebarCollapsedProvider.notifier)
                          .update((s) => !s),
                ),
                Expanded(
                  child: ClipRect(child: child),
                ),
              ],
            ),
          ),
        ],
      ),
      // Mobile drawer
      drawer: isMobile
          ? Drawer(
              width: AppConstants.sidebarWidthExpanded,
              child: const Sidebar(),
            )
          : null,
    );
  }
}
