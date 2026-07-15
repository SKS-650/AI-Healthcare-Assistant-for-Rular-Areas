/// Concrete implementation of [OfflineRepository].
///
/// All persistence goes through [LocalDbService] (Hive boxes).
/// Network sync calls go to the backend `/api/v1/offline/` endpoints.
/// Falls back gracefully on any error so the UI never crashes.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../config/api_config.dart';
import '../../../../core/local_db/local_db_service.dart';
import '../../data/models/offline_chat_entry_model.dart';
import '../../data/models/offline_symptom_result_model.dart';
import '../../data/models/sync_history_entry_model.dart';
import '../../data/models/sync_queue_item_model.dart';
import '../../domain/entities/cached_api_response.dart';
import '../../domain/entities/offline_chat_entry.dart';
import '../../domain/entities/offline_settings.dart';
import '../../domain/entities/offline_stats.dart';
import '../../domain/entities/offline_symptom_result.dart';
import '../../domain/entities/sync_history_entry.dart';
import '../../domain/entities/sync_queue_item.dart';
import '../../domain/enums/offline_enums.dart';
import '../../domain/repositories/offline_repository.dart';

class OfflineRepositoryImpl implements OfflineRepository {
  OfflineRepositoryImpl({String? authToken}) : _authToken = authToken;

  final _db   = LocalDbService.instance;
  final _uuid = const Uuid();

  /// Updated by the provider after login/logout.
  String? _authToken;
  void setAuthToken(String? token) => _authToken = token;

  // ── Auth header helper ───────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ─────────────────────────────────────────────────────────────────────────
  // Queue
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    final model = SyncQueueItemModel(
      id:            item.id,
      operationType: item.operationType,
      endpoint:      item.endpoint,
      payload:       item.payload,
      status:        item.status,
      retryCount:    item.retryCount,
      createdAt:     item.createdAt,
      updatedAt:     item.updatedAt,
      errorMessage:  item.errorMessage,
    );
    await _db.enqueueSyncItem(model);
  }

  @override
  Future<List<SyncQueueItem>> getPendingQueue() =>
      _db.loadPendingSyncQueue();

  @override
  Future<void> updateQueueItem(SyncQueueItem item) async {
    final model = SyncQueueItemModel(
      id:            item.id,
      operationType: item.operationType,
      endpoint:      item.endpoint,
      payload:       item.payload,
      status:        item.status,
      retryCount:    item.retryCount,
      createdAt:     item.createdAt,
      updatedAt:     item.updatedAt,
      errorMessage:  item.errorMessage,
    );
    await _db.updateSyncItem(model);
  }

  @override
  Future<void> removeQueueItem(String id) => _db.deleteSyncItem(id);

  @override
  Future<void> clearCompletedQueue() => _db.clearCompletedSyncItems();

  @override
  Future<int> getPendingCount() => _db.pendingSyncCount();

  // ─────────────────────────────────────────────────────────────────────────
  // Symptom results
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveSymptomResult(OfflineSymptomResult result) async {
    final model = OfflineSymptomResultModel(
      id:                  result.id,
      symptoms:            result.symptoms,
      primaryDisease:      result.primaryDisease,
      confidence:          result.confidence,
      riskLevel:           result.riskLevel,
      topDiseases:         result.topDiseases,
      recommendations:     result.recommendations,
      dietRecommendations: result.dietRecommendations,
      precautions:         result.precautions,
      workouts:            result.workouts,
      isEmergency:         result.isEmergency,
      criticalSymptoms:    result.criticalSymptoms,
      createdAt:           result.createdAt,
      age:                 result.age,
      gender:              result.gender,
      isSynced:            result.isSynced,
    );
    await _db.saveOfflineSymptomResult(model);
  }

  @override
  Future<List<OfflineSymptomResult>> getSymptomResults({int limit = 20}) =>
      _db.loadOfflineSymptomResults(limit: limit);

  @override
  Future<void> markSymptomResultSynced(String id) =>
      _db.markSymptomResultSynced(id);

  @override
  Future<List<OfflineSymptomResult>> getUnsyncedSymptomResults() =>
      _db.loadUnsyncedSymptomResults();

  // ─────────────────────────────────────────────────────────────────────────
  // Chat entries
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveChatEntry(OfflineChatEntry entry) async {
    final model = OfflineChatEntryModel(
      id:             entry.id,
      userMessage:    entry.userMessage,
      botResponse:    entry.botResponse,
      source:         entry.source,
      createdAt:      entry.createdAt,
      conversationId: entry.conversationId,
      isSynced:       entry.isSynced,
    );
    await _db.saveOfflineChatEntry(model);
  }

  @override
  Future<List<OfflineChatEntry>> getChatEntries({int limit = 50}) =>
      _db.loadOfflineChatEntries(limit: limit);

  @override
  Future<List<OfflineChatEntry>> getUnsyncedChatEntries() =>
      _db.loadUnsyncedChatEntries();

  @override
  Future<void> markChatEntrySynced(String id) =>
      _db.markChatEntrySynced(id);

  // ─────────────────────────────────────────────────────────────────────────
  // API response cache
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> cacheApiResponse(CachedApiResponse response) =>
      _db.cacheApiResponseEntry(response);

  @override
  Future<CachedApiResponse?> getCachedApiResponse(String cacheKey) =>
      _db.getApiResponseEntry(cacheKey);

  @override
  Future<void> evictExpiredCache() => _db.evictExpiredApiCache();

  @override
  Future<int> getCachedResponseCount() => _db.apiCacheCount();

  // ─────────────────────────────────────────────────────────────────────────
  // Sync history
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> addSyncHistory(SyncHistoryEntry entry) async {
    final model = SyncHistoryEntryModel(
      id:          entry.id,
      syncType:    entry.syncType,
      status:      entry.status,
      syncedItems: entry.syncedItems,
      failedItems: entry.failedItems,
      createdAt:   entry.createdAt,
      details:     entry.details,
      durationMs:  entry.durationMs,
    );
    await _db.addSyncHistory(model);
  }

  @override
  Future<List<SyncHistoryEntry>> getSyncHistory({int limit = 30}) =>
      _db.loadSyncHistory(limit: limit);

  // ─────────────────────────────────────────────────────────────────────────
  // Settings
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<OfflineSettings> loadSettings() async {
    await _db.initialize();
    return _db.loadOfflineSettings();
  }

  @override
  Future<void> saveSettings(OfflineSettings settings) =>
      _db.saveOfflineSettings(settings);

  // ─────────────────────────────────────────────────────────────────────────
  // Stats
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<OfflineStats> getStats() async {
    final raw          = await _db.getOfflineStats();
    final settings     = _db.loadOfflineSettings();
    final pendingCount = await _db.pendingSyncCount();
    final eduOffline   = (await _db.loadOfflineArticles()).length;
    final historyCount = (await _db.loadSyncHistory(limit: 200)).length;

    return OfflineStats(
      pendingQueueItems:    pendingCount,
      cachedArticles:       eduOffline,
      cachedSymptomResults: raw['symptom_cache'] ?? 0,
      cachedChatMessages:   raw['offline_chat']  ?? 0,
      cachedApiResponses:   raw['api_cache']     ?? 0,
      totalCacheSizeKb:     _estimateCacheSizeKb(raw),
      lastSyncAt:           settings.lastSyncAt,
      syncHistoryCount:     historyCount,
    );
  }

  double _estimateCacheSizeKb(Map<String, int> counts) {
    // Very rough estimate: average 2 KB per entry
    final total = counts.values.fold(0, (sum, v) => sum + v);
    return (total * 2.0);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Upload (local → server)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<SyncResult> syncToServer() async {
    final start   = DateTime.now();
    final pending = await _db.loadPendingSyncQueue();

    if (pending.isEmpty) {
      return SyncResult.success(synced: 0, durationMs: 0);
    }

    int synced = 0;
    int failed = 0;
    final errors = <String>[];

    for (final item in pending) {
      try {
        // Mark as in-progress
        await _db.updateSyncItem(item.withStatus(QueueItemStatus.inProgress));

        final response = await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}${item.endpoint}'),
              headers: _headers,
              body: item.payload,
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          await _db.updateSyncItem(item.withStatus(QueueItemStatus.completed));
          synced++;
        } else {
          final err = 'HTTP ${response.statusCode}: ${response.body}';
          await _db.updateSyncItem(item.withStatus(QueueItemStatus.failed, error: err));
          failed++;
          errors.add('${item.operationType.label}: $err');
        }
      } catch (e) {
        await _db.updateSyncItem(
            item.withStatus(QueueItemStatus.failed, error: e.toString()));
        failed++;
        errors.add('${item.operationType.label}: $e');
      }
    }

    await _db.clearCompletedSyncItems();

    final duration = DateTime.now().difference(start).inMilliseconds;
    final status   = failed == 0
        ? SyncStatus.success
        : (synced > 0 ? SyncStatus.partial : SyncStatus.failed);

    final historyEntry = SyncHistoryEntryModel(
      id:          _uuid.v4(),
      syncType:    'upload',
      status:      status,
      syncedItems: synced,
      failedItems: failed,
      createdAt:   DateTime.now(),
      durationMs:  duration,
      details:     errors.isNotEmpty ? errors.join('; ') : null,
    );
    await _db.addSyncHistory(historyEntry);
    await _db.updateLastSyncTime(DateTime.now());

    return SyncResult(
      status:      status,
      syncedItems: synced,
      failedItems: failed,
      durationMs:  duration,
      errors:      errors,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Download (server → local)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<SyncResult> syncFromServer() async {
    final start = DateTime.now();
    int synced  = 0;
    int failed  = 0;
    final errors = <String>[];

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/offline/download/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Cache the raw response for later offline use
        final cacheEntry = CachedApiResponse(
          id:        _uuid.v4(),
          cacheKey:  'offline_download_latest',
          response:  response.body,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );
        await _db.cacheApiResponseEntry(cacheEntry);

        synced = (data['synced_items'] as int?) ?? 1;
      } else {
        failed = 1;
        errors.add('Download failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      failed = 1;
      errors.add('Download error: $e');
    }

    final duration = DateTime.now().difference(start).inMilliseconds;
    final status   = failed == 0 ? SyncStatus.success : SyncStatus.failed;

    final historyEntry = SyncHistoryEntryModel(
      id:          _uuid.v4(),
      syncType:    'download',
      status:      status,
      syncedItems: synced,
      failedItems: failed,
      createdAt:   DateTime.now(),
      durationMs:  duration,
      details:     errors.isNotEmpty ? errors.join('; ') : null,
    );
    await _db.addSyncHistory(historyEntry);
    if (synced > 0) await _db.updateLastSyncTime(DateTime.now());

    return SyncResult(
      status:      status,
      syncedItems: synced,
      failedItems: failed,
      durationMs:  duration,
      errors:      errors,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Full bidirectional sync
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<SyncResult> fullSync() async {
    final start  = DateTime.now();
    final upload = await syncToServer();
    final download = await syncFromServer();

    final totalSynced = upload.syncedItems + download.syncedItems;
    final totalFailed = upload.failedItems + download.failedItems;
    final errors      = [...upload.errors, ...download.errors];
    final duration    = DateTime.now().difference(start).inMilliseconds;

    final status = totalFailed == 0
        ? SyncStatus.success
        : (totalSynced > 0 ? SyncStatus.partial : SyncStatus.failed);

    final historyEntry = SyncHistoryEntryModel(
      id:          _uuid.v4(),
      syncType:    'full',
      status:      status,
      syncedItems: totalSynced,
      failedItems: totalFailed,
      createdAt:   DateTime.now(),
      durationMs:  duration,
      details:     errors.isNotEmpty ? errors.take(5).join('; ') : null,
    );
    await _db.addSyncHistory(historyEntry);
    await _db.updateLastSyncTime(DateTime.now());

    return SyncResult(
      status:      status,
      syncedItems: totalSynced,
      failedItems: totalFailed,
      durationMs:  duration,
      errors:      errors,
    );
  }
}
