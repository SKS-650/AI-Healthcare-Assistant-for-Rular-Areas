/// All Riverpod providers for the Offline module.
///
/// Dependency graph:
///   offlineRepositoryProvider
///       └─> offlineSyncServiceProvider
///               └─> offlineStatsProvider
///                   offlineSettingsProvider
///                   offlineSyncStatusProvider
///                   syncHistoryProvider
///                   pendingQueueProvider
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../data/repositories/offline_repository_impl.dart';
import '../../data/services/offline_sync_service.dart';
import '../../domain/entities/offline_settings.dart';
import '../../domain/entities/offline_stats.dart';
import '../../domain/entities/sync_history_entry.dart';
import '../../domain/entities/sync_queue_item.dart';
import '../../domain/enums/offline_enums.dart';
import '../../domain/repositories/offline_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Core singletons
// ─────────────────────────────────────────────────────────────────────────────

/// The concrete [OfflineRepository].
final offlineRepositoryProvider = Provider<OfflineRepository>((ref) {
  return OfflineRepositoryImpl();
});

/// The sync orchestrator. Started once; disposed with the provider.
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final repo    = ref.watch(offlineRepositoryProvider);
  final network = ref.watch(networkInfoProvider);

  final service = OfflineSyncService(
    repository:  repo,
    networkInfo: network,
  );

  // Start connectivity watcher immediately.
  service.startWatching();

  ref.onDispose(service.dispose);
  return service;
});

// ─────────────────────────────────────────────────────────────────────────────
// Sync status stream
// ─────────────────────────────────────────────────────────────────────────────

/// Live [SyncStatus] stream coming from [OfflineSyncService].
final offlineSyncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final service = ref.watch(offlineSyncServiceProvider);
  return service.onStatusChange;
});

// ─────────────────────────────────────────────────────────────────────────────
// Stats (refreshed on demand via [offlineStatsNotifierProvider])
// ─────────────────────────────────────────────────────────────────────────────

class OfflineStatsNotifier extends AsyncNotifier<OfflineStats> {
  @override
  Future<OfflineStats> build() async {
    return ref.watch(offlineRepositoryProvider).getStats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(offlineRepositoryProvider).getStats(),
    );
  }
}

final offlineStatsNotifierProvider =
    AsyncNotifierProvider<OfflineStatsNotifier, OfflineStats>(
        OfflineStatsNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Settings
// ─────────────────────────────────────────────────────────────────────────────

class OfflineSettingsNotifier extends AsyncNotifier<OfflineSettings> {
  @override
  Future<OfflineSettings> build() async {
    return ref.watch(offlineRepositoryProvider).loadSettings();
  }

  Future<void> toggleOfflineMode(bool value) async {
    final current = state.valueOrNull ?? const OfflineSettings();
    final updated = current.copyWith(offlineModeEnabled: value);
    await ref.read(offlineRepositoryProvider).saveSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> toggleAutoSync(bool value) async {
    final current = state.valueOrNull ?? const OfflineSettings();
    final updated = current.copyWith(autoSyncEnabled: value);
    await ref.read(offlineRepositoryProvider).saveSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> toggleWifiOnly(bool value) async {
    final current = state.valueOrNull ?? const OfflineSettings();
    final updated = current.copyWith(syncOnWifiOnly: value);
    await ref.read(offlineRepositoryProvider).saveSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> toggleCacheArticles(bool value) async {
    final current = state.valueOrNull ?? const OfflineSettings();
    final updated = current.copyWith(cacheArticlesForOffline: value);
    await ref.read(offlineRepositoryProvider).saveSettings(updated);
    state = AsyncData(updated);
  }
}

final offlineSettingsNotifierProvider =
    AsyncNotifierProvider<OfflineSettingsNotifier, OfflineSettings>(
        OfflineSettingsNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Sync history list
// ─────────────────────────────────────────────────────────────────────────────

class SyncHistoryNotifier extends AsyncNotifier<List<SyncHistoryEntry>> {
  @override
  Future<List<SyncHistoryEntry>> build() async {
    return ref.watch(offlineRepositoryProvider).getSyncHistory(limit: 30);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(offlineRepositoryProvider).getSyncHistory(limit: 30),
    );
  }
}

final syncHistoryNotifierProvider =
    AsyncNotifierProvider<SyncHistoryNotifier, List<SyncHistoryEntry>>(
        SyncHistoryNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Pending queue list
// ─────────────────────────────────────────────────────────────────────────────

class PendingQueueNotifier extends AsyncNotifier<List<SyncQueueItem>> {
  @override
  Future<List<SyncQueueItem>> build() async {
    return ref.watch(offlineRepositoryProvider).getPendingQueue();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(offlineRepositoryProvider).getPendingQueue(),
    );
  }

  Future<void> clearCompleted() async {
    await ref.read(offlineRepositoryProvider).clearCompletedQueue();
    await refresh();
    ref.read(offlineStatsNotifierProvider.notifier).refresh();
  }
}

final pendingQueueNotifierProvider =
    AsyncNotifierProvider<PendingQueueNotifier, List<SyncQueueItem>>(
        PendingQueueNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Manual sync action provider
// ─────────────────────────────────────────────────────────────────────────────

class ManualSyncNotifier extends AsyncNotifier<SyncResult?> {
  @override
  Future<SyncResult?> build() async => null;

  Future<void> sync() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(offlineSyncServiceProvider)
          .triggerSync(syncType: 'manual');

      // Refresh dependent providers after sync.
      ref.read(offlineStatsNotifierProvider.notifier).refresh();
      ref.read(syncHistoryNotifierProvider.notifier).refresh();
      ref.read(pendingQueueNotifierProvider.notifier).refresh();

      return result;
    });
  }
}

final manualSyncNotifierProvider =
    AsyncNotifierProvider<ManualSyncNotifier, SyncResult?>(
        ManualSyncNotifier.new);
