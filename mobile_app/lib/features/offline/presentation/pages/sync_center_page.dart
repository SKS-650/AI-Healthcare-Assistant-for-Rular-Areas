import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/network_info.dart';
import '../../application/providers/offline_providers.dart';
import '../../domain/entities/sync_history_entry.dart';
import '../../domain/entities/sync_queue_item.dart';
import '../../domain/enums/offline_enums.dart';

class SyncCenterPage extends ConsumerStatefulWidget {
  const SyncCenterPage({super.key});

  @override
  ConsumerState<SyncCenterPage> createState() => _SyncCenterPageState();
}

class _SyncCenterPageState extends ConsumerState<SyncCenterPage>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF6C63FF);
  static const _green   = Color(0xFF4CAF50);
  static const _orange  = Color(0xFFFF9800);
  static const _red     = Color(0xFFF44336);
  static const _bg      = Color(0xFFF0EFFF);

  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _refreshAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _refreshAll() {
    ref.read(pendingQueueNotifierProvider.notifier).refresh();
    ref.read(syncHistoryNotifierProvider.notifier).refresh();
    ref.read(offlineSettingsNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline     = ref.watch(isOnlineProvider);
    final syncAsync    = ref.watch(offlineSyncStatusProvider);
    final manualAsync  = ref.watch(manualSyncNotifierProvider);

    final syncing = syncAsync.maybeWhen(
      data:    (s) => s == SyncStatus.syncing,
      orElse:  () => false,
    ) || manualAsync.isLoading;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Row(children: [
          Text('🔄', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Sync Center'),
        ]),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Queue'),
            Tab(text: 'History'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSyncHeader(isOnline, syncing),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildQueueTab(),
                _buildHistoryTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isOnline
          ? FloatingActionButton.extended(
              backgroundColor: syncing ? Colors.grey : _primary,
              onPressed: syncing
                  ? null
                  : () => ref.read(manualSyncNotifierProvider.notifier).sync(),
              icon: syncing
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.sync_rounded),
              label: Text(syncing ? 'Syncing…' : 'Sync Now'),
            )
          : null,
    );
  }

  // ── Sync header ───────────────────────────────────────────────────────────

  Widget _buildSyncHeader(bool isOnline, bool syncing) {
    final Color color;
    final String text;
    final IconData icon;

    if (syncing) {
      color = _orange; text = '🟡 Synchronizing…'; icon = Icons.sync_rounded;
    } else if (isOnline) {
      color = _green;  text = '🟢 Online — ready to sync'; icon = Icons.cloud_done_rounded;
    } else {
      color = _red;    text = '🔴 Offline — connect to sync'; icon = Icons.cloud_off_rounded;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        syncing
            ? SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }

  // ── Queue tab ─────────────────────────────────────────────────────────────

  Widget _buildQueueTab() {
    final queueAsync = ref.watch(pendingQueueNotifierProvider);
    return queueAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error: $e')),
      data:    (items) => items.isEmpty
          ? _buildEmptyState('✅ No pending items', 'All data is synced.')
          : _buildQueueList(items),
    );
  }

  Widget _buildQueueList(List<SyncQueueItem> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            Text('${items.length} pending',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            TextButton.icon(
              onPressed: () =>
                  ref.read(pendingQueueNotifierProvider.notifier).clearCompleted(),
              icon: const Icon(Icons.clear_all_rounded, size: 16),
              label: const Text('Clear Completed', style: TextStyle(fontSize: 12)),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _buildQueueItem(items[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildQueueItem(SyncQueueItem item, int index) {
    final statusColor = switch (item.status) {
      QueueItemStatus.completed  => _green,
      QueueItemStatus.failed     => _red,
      QueueItemStatus.inProgress => _orange,
      _                          => Colors.blueGrey,
    };
    final statusIcon = switch (item.status) {
      QueueItemStatus.completed  => Icons.check_circle_rounded,
      QueueItemStatus.failed     => Icons.error_rounded,
      QueueItemStatus.inProgress => Icons.sync_rounded,
      _                          => Icons.schedule_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Icon(statusIcon, color: statusColor, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.operationType.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(item.endpoint,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          if (item.errorMessage != null)
            Text('Error: ${item.errorMessage}',
                style: const TextStyle(color: _red, fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(item.status.name,
                style: TextStyle(
                    color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 4),
          Text('Retry ${item.retryCount}/3',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
        ]),
      ]),
    ).animate(delay: (index * 40).ms).fadeIn(duration: 250.ms);
  }

  // ── History tab ───────────────────────────────────────────────────────────

  Widget _buildHistoryTab() {
    final histAsync = ref.watch(syncHistoryNotifierProvider);
    return histAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error: $e')),
      data:    (history) => history.isEmpty
          ? _buildEmptyState('📋 No sync history', 'Sync events will appear here.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (ctx, i) => _buildHistoryItem(history[i], i),
            ),
    );
  }

  Widget _buildHistoryItem(SyncHistoryEntry entry, int index) {
    final statusColor = switch (entry.status) {
      SyncStatus.success => _green,
      SyncStatus.failed  => _red,
      SyncStatus.partial => _orange,
      _                  => Colors.blueGrey,
    };
    final statusEmoji = switch (entry.status) {
      SyncStatus.success => '✅',
      SyncStatus.failed  => '❌',
      SyncStatus.partial => '⚠️',
      _                  => '⏳',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Text(statusEmoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(entry.syncType.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(entry.status.name,
                  style: TextStyle(color: statusColor, fontSize: 10)),
            ),
          ]),
          const SizedBox(height: 3),
          Text(
            '${entry.syncedItems} synced · ${entry.failedItems} failed'
            '${entry.durationMs != null ? " · ${entry.durationMs}ms" : ""}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
          Text(DateFormat('MMM d, y  HH:mm').format(entry.createdAt.toLocal()),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
          if (entry.details != null && entry.details!.isNotEmpty)
            Text(entry.details!,
                style: const TextStyle(color: _red, fontSize: 11),
                maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    ).animate(delay: (index * 40).ms).fadeIn(duration: 250.ms);
  }

  // ── Settings tab ──────────────────────────────────────────────────────────

  Widget _buildSettingsTab() {
    final settingsAsync = ref.watch(offlineSettingsNotifierProvider);
    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error: $e')),
      data:    (settings) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsTile(
            icon: Icons.offline_bolt_rounded, color: _primary,
            title: 'Offline Mode',
            subtitle: 'Enable offline data storage and AI features',
            value: settings.offlineModeEnabled,
            onChanged: (v) => ref
                .read(offlineSettingsNotifierProvider.notifier)
                .toggleOfflineMode(v),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.sync_rounded, color: _green,
            title: 'Auto Sync',
            subtitle: 'Automatically sync when internet is restored',
            value: settings.autoSyncEnabled,
            onChanged: (v) => ref
                .read(offlineSettingsNotifierProvider.notifier)
                .toggleAutoSync(v),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.wifi_rounded, color: _orange,
            title: 'Wi-Fi Only Sync',
            subtitle: 'Only sync when connected to Wi-Fi',
            value: settings.syncOnWifiOnly,
            onChanged: (v) => ref
                .read(offlineSettingsNotifierProvider.notifier)
                .toggleWifiOnly(v),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.article_rounded, color: const Color(0xFF00BCD4),
            title: 'Cache Articles',
            subtitle: 'Store health articles for offline reading',
            value: settings.cacheArticlesForOffline,
            onChanged: (v) => ref
                .read(offlineSettingsNotifierProvider.notifier)
                .toggleCacheArticles(v),
          ),
          const SizedBox(height: 24),
          if (settings.lastSyncAt != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.access_time_rounded, color: Colors.blueGrey, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Last synced: ${DateFormat('MMM d, y  HH:mm').format(settings.lastSyncAt!.toLocal())}',
                  style: const TextStyle(fontSize: 13),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ])),
          Switch(value: value, onChanged: onChanged, thumbColor: WidgetStatePropertyAll(_primary)),
        ]),
      );

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(String emoji, String message) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text(message,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
    ]),
  );
}
