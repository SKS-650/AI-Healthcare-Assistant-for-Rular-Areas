import '../entities/cached_api_response.dart';
import '../entities/offline_chat_entry.dart';
import '../entities/offline_settings.dart';
import '../entities/offline_stats.dart';
import '../entities/offline_symptom_result.dart';
import '../entities/sync_history_entry.dart';
import '../entities/sync_queue_item.dart';
import '../enums/offline_enums.dart';

/// Abstract contract for all offline storage and sync operations.
abstract class OfflineRepository {
  // ── Queue ────────────────────────────────────────────────────────────────
  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> getPendingQueue();
  Future<void> updateQueueItem(SyncQueueItem item);
  Future<void> removeQueueItem(String id);
  Future<void> clearCompletedQueue();
  Future<int> getPendingCount();

  // ── Symptom results ──────────────────────────────────────────────────────
  Future<void> saveSymptomResult(OfflineSymptomResult result);
  Future<List<OfflineSymptomResult>> getSymptomResults({int limit = 20});
  Future<void> markSymptomResultSynced(String id);
  Future<List<OfflineSymptomResult>> getUnsyncedSymptomResults();

  // ── Chat entries ─────────────────────────────────────────────────────────
  Future<void> saveChatEntry(OfflineChatEntry entry);
  Future<List<OfflineChatEntry>> getChatEntries({int limit = 50});
  Future<List<OfflineChatEntry>> getUnsyncedChatEntries();
  Future<void> markChatEntrySynced(String id);

  // ── API response cache ────────────────────────────────────────────────────
  Future<void> cacheApiResponse(CachedApiResponse response);
  Future<CachedApiResponse?> getCachedApiResponse(String cacheKey);
  Future<void> evictExpiredCache();
  Future<int> getCachedResponseCount();

  // ── Sync history ──────────────────────────────────────────────────────────
  Future<void> addSyncHistory(SyncHistoryEntry entry);
  Future<List<SyncHistoryEntry>> getSyncHistory({int limit = 30});

  // ── Settings ──────────────────────────────────────────────────────────────
  Future<OfflineSettings> loadSettings();
  Future<void> saveSettings(OfflineSettings settings);

  // ── Stats ─────────────────────────────────────────────────────────────────
  Future<OfflineStats> getStats();

  // ── Sync ──────────────────────────────────────────────────────────────────

  /// Upload all pending queue items to the server. Returns [SyncResult].
  Future<SyncResult> syncToServer();

  /// Download updated data from the server into local cache.
  Future<SyncResult> syncFromServer();

  /// Full bidirectional sync.
  Future<SyncResult> fullSync();
}

// ─────────────────────────────────────────────────────────────────────────────
// Value object returned from sync operations
// ─────────────────────────────────────────────────────────────────────────────

class SyncResult {
  const SyncResult({
    required this.status,
    required this.syncedItems,
    required this.failedItems,
    required this.durationMs,
    this.errors = const [],
  });

  final SyncStatus status;
  final int syncedItems;
  final int failedItems;
  final int durationMs;
  final List<String> errors;

  bool get isSuccess => status == SyncStatus.success;

  factory SyncResult.success({required int synced, required int durationMs}) =>
      SyncResult(
        status:      SyncStatus.success,
        syncedItems: synced,
        failedItems: 0,
        durationMs:  durationMs,
      );

  factory SyncResult.failed(String error) => SyncResult(
        status:      SyncStatus.failed,
        syncedItems: 0,
        failedItems: 1,
        durationMs:  0,
        errors:      [error],
      );
}
