import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/network_info.dart';
import '../../application/providers/offline_providers.dart';
import '../../domain/entities/offline_stats.dart';
import '../../domain/enums/offline_enums.dart';
import 'offline_chatbot_page.dart';
import 'offline_symptom_checker_page.dart';
import 'sync_center_page.dart';

class OfflineDashboardPage extends ConsumerStatefulWidget {
  const OfflineDashboardPage({super.key});

  @override
  ConsumerState<OfflineDashboardPage> createState() =>
      _OfflineDashboardPageState();
}

class _OfflineDashboardPageState extends ConsumerState<OfflineDashboardPage> {
  // ── Design tokens ──────────────────────────────────────────────────────────
  static const _purple    = Color(0xFF6C63FF);
  static const _teal      = Color(0xFF00BCD4);
  static const _green     = Color(0xFF4CAF50);
  static const _orange    = Color(0xFFFF9800);
  static const _red       = Color(0xFFF44336);
  static const _bg        = Color(0xFFF0EFFF);
  static const _cardBg    = Colors.white;

  @override
  void initState() {
    super.initState();
    // Refresh stats when page opens
    Future.microtask(
        () => ref.read(offlineStatsNotifierProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    final statsAsync        = ref.watch(offlineStatsNotifierProvider);
    final syncStatusAsync   = ref.watch(offlineSyncStatusProvider);

    final isOnline = connectivityAsync.maybeWhen(
      data: (s) => s == ConnectivityStatus.online,
      orElse: () => false,
    );
    final syncStatus = syncStatusAsync.maybeWhen(
      data: (s) => s,
      orElse: () => SyncStatus.idle,
    );

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isOnline, syncStatus),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildStatusCard(isOnline, syncStatus),
                const SizedBox(height: 20),
                statsAsync.when(
                  loading: () => _buildStatsSkeleton(),
                  error:   (_, __) => const SizedBox.shrink(),
                  data:    (stats) => _buildStatsGrid(stats),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('📱 Offline Features'),
                const SizedBox(height: 14),
                _buildFeatureGrid(context),
                const SizedBox(height: 24),
                _buildSectionTitle('⚡ Quick Actions'),
                const SizedBox(height: 14),
                _buildQuickActions(context, isOnline),
                const SizedBox(height: 24),
                statsAsync.maybeWhen(
                  data: (s) => _buildLastSyncCard(s),
                  orElse: () => const SizedBox.shrink(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(bool isOnline, SyncStatus syncStatus) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: _purple,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.offline_bolt_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        'Offline Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _buildStatusPill(isOnline, syncStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOnline
                        ? 'Connected — full features available'
                        : 'Offline — local features active',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Refresh stats',
          onPressed: () =>
              ref.read(offlineStatsNotifierProvider.notifier).refresh(),
        ),
      ],
    );
  }

  Widget _buildStatusPill(bool isOnline, SyncStatus syncStatus) {
    final Color color;
    final String label;
    final IconData icon;

    if (syncStatus == SyncStatus.syncing) {
      color = _orange;
      label = 'Syncing…';
      icon  = Icons.sync_rounded;
    } else if (isOnline) {
      color = _green;
      label = 'Online';
      icon  = Icons.wifi_rounded;
    } else {
      color = _red;
      label = 'Offline';
      icon  = Icons.wifi_off_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          syncStatus == SyncStatus.syncing
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: color,
                  ),
                )
              : Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Status card ───────────────────────────────────────────────────────────

  Widget _buildStatusCard(bool isOnline, SyncStatus syncStatus) {
    final Color accent = isOnline ? _green : _orange;
    final String title = isOnline
        ? '🟢 You are Online'
        : '🔴 You are Offline';
    final String subtitle = isOnline
        ? 'All features available. Data will sync automatically.'
        : 'No internet connection. Using cached data and local AI.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Stats grid ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(OfflineStats stats) {
    final items = [
      _StatItem(
        icon:  Icons.pending_actions_rounded,
        color: _orange,
        label: 'Pending Sync',
        value: '${stats.pendingQueueItems}',
      ),
      _StatItem(
        icon:  Icons.article_rounded,
        color: _teal,
        label: 'Cached Articles',
        value: '${stats.cachedArticles}',
      ),
      _StatItem(
        icon:  Icons.medical_services_rounded,
        color: _purple,
        label: 'Assessments',
        value: '${stats.cachedSymptomResults}',
      ),
      _StatItem(
        icon:  Icons.chat_bubble_rounded,
        color: _green,
        label: 'Chat History',
        value: '${stats.cachedChatMessages}',
      ),
      _StatItem(
        icon:  Icons.storage_rounded,
        color: const Color(0xFFE91E63),
        label: 'Cache Size',
        value: '${stats.totalCacheSizeKb.toStringAsFixed(0)} KB',
      ),
      _StatItem(
        icon:  Icons.history_rounded,
        color: Colors.blueGrey,
        label: 'Sync Events',
        value: '${stats.syncHistoryCount}',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:    3,
        crossAxisSpacing:  12,
        mainAxisSpacing:   12,
        childAspectRatio:  1.05,
      ),
      itemBuilder: (ctx, i) => _buildStatCard(items[i], i),
    );
  }

  Widget _buildStatCard(_StatItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(item.value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: item.color)),
          const SizedBox(height: 3),
          Text(item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.85, 0.85));
  }

  Widget _buildStatsSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ── Feature grid ──────────────────────────────────────────────────────────

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        emoji: '🤒',
        title: 'Symptom\nChecker',
        color: _purple,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OfflineSymptomCheckerPage()),
        ),
      ),
      _FeatureItem(
        emoji: '🤖',
        title: 'Medical\nChatbot',
        color: _teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OfflineChatbotPage()),
        ),
      ),
      _FeatureItem(
        emoji: '🔄',
        title: 'Sync\nCenter',
        color: _orange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SyncCenterPage()),
        ),
      ),
      _FeatureItem(
        emoji: '🩺',
        title: 'Medical\nRecords',
        color: const Color(0xFFE91E63),
        onTap: () => Navigator.pushNamed(context, '/records'),
      ),
      _FeatureItem(
        emoji: '📚',
        title: 'Offline\nArticles',
        color: _green,
        onTap: () => Navigator.pushNamed(context, '/health-education'),
      ),
      _FeatureItem(
        emoji: '🚨',
        title: 'Emergency\nGuide',
        color: _red,
        onTap: () => Navigator.pushNamed(context, '/emergency'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (ctx, i) {
        final f = features[i];
        return GestureDetector(
          onTap: f.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: f.color.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: f.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(f.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 8),
                Text(
                  f.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ).animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideY(begin: 0.15, end: 0),
        );
      },
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, bool isOnline) {
    return Column(
      children: [
        _buildActionTile(
          icon:    Icons.sync_rounded,
          color:   _purple,
          title:   'Manual Sync',
          subtitle: isOnline
              ? 'Sync all pending data to server'
              : 'Connect to internet to sync',
          trailing: isOnline
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => ref
                      .read(manualSyncNotifierProvider.notifier)
                      .sync(),
                  icon: const Icon(Icons.sync_rounded, size: 14),
                  label: const Text('Sync Now'),
                )
              : const Icon(Icons.cloud_off_rounded,
                  color: Colors.grey, size: 20),
          onTap: isOnline
              ? () => ref
                  .read(manualSyncNotifierProvider.notifier)
                  .sync()
              : null,
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon:    Icons.delete_sweep_rounded,
          color:   Colors.redAccent,
          title:   'Clear Expired Cache',
          subtitle: 'Remove outdated cached responses',
          onTap: () async {
            await ref
                .read(offlineRepositoryProvider)
                .evictExpiredCache();
            ref.read(offlineStatsNotifierProvider.notifier).refresh();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Expired cache cleared'),
                    duration: Duration(seconds: 2)),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon:    Icons.settings_rounded,
          color:   Colors.blueGrey,
          title:   'Offline Settings',
          subtitle: 'Configure auto-sync and cache preferences',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SyncCenterPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ── Last sync card ────────────────────────────────────────────────────────

  Widget _buildLastSyncCard(OfflineStats stats) {
    final lastSync = stats.lastSyncAt;
    final text = lastSync == null
        ? 'Never synced'
        : 'Last synced: ${DateFormat('MMM d, y  HH:mm').format(lastSync.toLocal())}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, color: _teal, size: 18),
          const SizedBox(width: 10),
          Text(text,
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2D3A)),
      );
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _StatItem {
  const _StatItem(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});
  final IconData icon;
  final Color    color;
  final String   label;
  final String   value;
}

class _FeatureItem {
  const _FeatureItem(
      {required this.emoji,
      required this.title,
      required this.color,
      required this.onTap});
  final String       emoji;
  final String       title;
  final Color        color;
  final VoidCallback onTap;
}
