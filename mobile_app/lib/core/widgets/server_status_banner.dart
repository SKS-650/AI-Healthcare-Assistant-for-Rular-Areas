/// Reusable connection-status banner / chip widget.
///
/// Drop anywhere in the widget tree — it listens to [serverStatusProvider]
/// and automatically shows / hides itself based on server reachability.
///
/// Usage — full banner (e.g. top of a page):
/// ```dart
/// const ServerStatusBanner()
/// ```
///
/// Usage — compact chip (e.g. inside an AppBar):
/// ```dart
/// const ServerStatusChip()
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/network_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color helpers
// ─────────────────────────────────────────────────────────────────────────────

extension _StatusColors on ServerStatus {
  Color get background => switch (this) {
        ServerStatus.connected => const Color(0xFF1B5E20),
        ServerStatus.serverOffline => const Color(0xFFB71C1C),
        ServerStatus.noInternet => const Color(0xFFE65100),
        ServerStatus.checking => const Color(0xFF0D47A1),
      };

  Color get foreground => Colors.white;

  IconData get icon => switch (this) {
        ServerStatus.connected => Icons.wifi,
        ServerStatus.serverOffline => Icons.cloud_off_rounded,
        ServerStatus.noInternet => Icons.wifi_off_rounded,
        ServerStatus.checking => Icons.sync_rounded,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-width banner
// ─────────────────────────────────────────────────────────────────────────────

/// Shows a dismissible banner at the top of a page when the server is not
/// reachable.  Hidden automatically when the status becomes [ServerStatus.connected].
class ServerStatusBanner extends ConsumerWidget {
  const ServerStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(serverStatusProvider);

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) {
        // Hide the banner when everything is fine
        if (status == ServerStatus.connected) return const SizedBox.shrink();

        return _BannerTile(status: status);
      },
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.status});
  final ServerStatus status;

  @override
  Widget build(BuildContext context) {
    final isChecking = status == ServerStatus.checking;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: status.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (isChecking)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(status.icon, color: status.foreground, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${status.emoji}  ${status.label}',
                    style: TextStyle(
                      color: status.foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (!isChecking) ...[
                    const SizedBox(height: 2),
                    Text(
                      status.hint,
                      style: TextStyle(
                        color: status.foreground.withOpacity(0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact chip (for AppBar actions, etc.)
// ─────────────────────────────────────────────────────────────────────────────

/// Small pill-shaped indicator that shows the current server status.
/// Tapping it shows a [SnackBar] with the full hint message.
class ServerStatusChip extends ConsumerWidget {
  const ServerStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(serverStatusProvider);

    return statusAsync.when(
      loading: () => const _ChipShell(
        status: ServerStatus.checking,
        label: 'Checking…',
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) => GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status.hint),
              backgroundColor: status.background,
              duration: const Duration(seconds: 4),
            ),
          );
        },
        child: _ChipShell(
          status: status,
          label: status.label,
        ),
      ),
    );
  }
}

class _ChipShell extends StatelessWidget {
  const _ChipShell({required this.status, required this.label});
  final ServerStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == ServerStatus.checking)
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
            )
          else
            Icon(status.icon, color: status.foreground, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: status.foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen error page (when server is offline at launch)
// ─────────────────────────────────────────────────────────────────────────────

/// Displays a full-screen error page with retry button when the server
/// cannot be reached.  Wrap your app's body with this via a [Consumer].
///
/// ```dart
/// Consumer(
///   builder: (context, ref, _) {
///     final status = ref.watch(serverStatusProvider);
///     return status.maybeWhen(
///       data: (s) => s == ServerStatus.serverOffline
///           ? ServerOfflinePage(onRetry: () => ref.invalidate(serverStatusProvider))
///           : child,
///       orElse: () => child,
///     );
///   },
/// )
/// ```
class ServerOfflinePage extends StatelessWidget {
  const ServerOfflinePage({
    super.key,
    this.status = ServerStatus.serverOffline,
    required this.onRetry,
  });

  final ServerStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status.icon,
                  size: 80,
                  color: status.background,
                ),
                const SizedBox(height: 24),
                Text(
                  '${status.emoji}  ${status.label}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  status.hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Backend: ${_backendUrl()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _backendUrl() {
    try {
      return 'http://192.168.18.26:8000';
    } catch (_) {
      return 'unknown';
    }
  }
}
