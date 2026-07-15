/// A slim animated connectivity banner shown at the top/bottom of screens.
///
/// Usage — wrap any screen body or insert below the AppBar:
///
/// ```dart
/// Column(children: [
///   const OfflineStatusBanner(),
///   Expanded(child: yourContent),
/// ])
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../application/providers/offline_providers.dart';
import '../../domain/enums/offline_enums.dart';

class OfflineStatusBanner extends ConsumerWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    final syncAsync         = ref.watch(offlineSyncStatusProvider);

    return connectivityAsync.when(
      loading: () => const SizedBox.shrink(),
      error:   (_, __) => const SizedBox.shrink(),
      data:    (connectivity) {
        final syncStatus = syncAsync.maybeWhen(
          data:   (s) => s,
          orElse: () => SyncStatus.idle,
        );

        if (connectivity == ConnectivityStatus.checking) {
          return const SizedBox.shrink();
        }

        // Show banner when offline OR when syncing
        if (connectivity == ConnectivityStatus.online &&
            syncStatus != SyncStatus.syncing) {
          return const SizedBox.shrink();
        }

        final bool isOffline  = connectivity == ConnectivityStatus.offline;
        final bool isSyncing  = syncStatus == SyncStatus.syncing;

        final Color bg;
        final Color fg;
        final String message;
        final IconData icon;

        if (isSyncing) {
          bg      = const Color(0xFFFFF3E0);
          fg      = const Color(0xFFE65100);
          message = '🟡 Synchronizing data…';
          icon    = Icons.sync_rounded;
        } else {
          bg      = const Color(0xFFFFEBEE);
          fg      = const Color(0xFFC62828);
          message = '🔴 No internet connection — offline mode active';
          icon    = Icons.wifi_off_rounded;
        }

        return Material(
          color: bg,
          child: InkWell(
            onTap: isSyncing
                ? null
                : () => _showOfflineDialog(context, ref),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Row(children: [
                isSyncing
                    ? SizedBox(
                        width: 13, height: 13,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: fg))
                    : Icon(icon, size: 13, color: fg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                        color: fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                if (!isSyncing && isOffline)
                  Icon(Icons.info_outline_rounded, size: 14, color: fg),
              ]),
            ),
          ),
        )
            .animate()
            .slideY(begin: -1, end: 0, duration: 300.ms, curve: Curves.easeOut)
            .fadeIn(duration: 250.ms);
      },
    );
  }

  void _showOfflineDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Text('📡', style: TextStyle(fontSize: 22)),
          SizedBox(width: 8),
          Text('Offline Mode', style: TextStyle(fontSize: 17)),
        ]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'re currently offline. The app is running in offline mode.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text('Available offline:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            SizedBox(height: 6),
            _OfflineFeatureTile(emoji: '🤒', label: 'Offline Symptom Checker'),
            _OfflineFeatureTile(emoji: '🤖', label: 'Offline Medical Chatbot'),
            _OfflineFeatureTile(emoji: '🩺', label: 'Cached Medical Records'),
            _OfflineFeatureTile(emoji: '📚', label: 'Downloaded Articles'),
            _OfflineFeatureTile(emoji: '🚨', label: 'Emergency Guide'),
            SizedBox(height: 12),
            Text(
              'Your actions are saved locally and will be synced automatically when internet is restored.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _OfflineFeatureTile extends StatelessWidget {
  const _OfflineFeatureTile({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating connectivity indicator (circular FAB-style)
// ─────────────────────────────────────────────────────────────────────────────

class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(connectivityStatusProvider);
    return async.maybeWhen(
      data: (status) {
        final Color color;
        final IconData icon;

        switch (status) {
          case ConnectivityStatus.online:
            color = const Color(0xFF4CAF50);
            icon  = Icons.wifi_rounded;
          case ConnectivityStatus.offline:
            color = const Color(0xFFF44336);
            icon  = Icons.wifi_off_rounded;
          case ConnectivityStatus.checking:
            color = const Color(0xFFFF9800);
            icon  = Icons.sync_rounded;
        }

        return Tooltip(
          message: status.name,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
