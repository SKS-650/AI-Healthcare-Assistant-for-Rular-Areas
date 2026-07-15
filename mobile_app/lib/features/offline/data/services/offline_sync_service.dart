/// OfflineSyncService — auto-sync orchestrator.
///
/// Responsibilities:
///   • Watch [NetworkInfo] for connectivity transitions.
///   • On reconnection: trigger automatic full sync (if settings allow).
///   • Expose a public [triggerSync] for manual sync from the UI.
///   • Emit [SyncStatus] so providers can update the UI accordingly.
library;

import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../../core/local_db/local_db_service.dart';
import '../../../../core/network/network_info.dart';
import '../../data/models/sync_queue_item_model.dart';
import '../../domain/entities/cached_api_response.dart';
import '../../domain/enums/offline_enums.dart';
import '../../domain/repositories/offline_repository.dart';

class OfflineSyncService {
  OfflineSyncService({
    required OfflineRepository repository,
    required NetworkInfo networkInfo,
  })  : _repo        = repository,
        _networkInfo = networkInfo;

  final OfflineRepository _repo;
  final NetworkInfo       _networkInfo;
  final _uuid             = const Uuid();

  // ── State ─────────────────────────────────────────────────────────────────

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get onStatusChange => _statusController.stream;

  StreamSubscription<ConnectivityStatus>? _connectivitySub;
  bool _wasOffline = false;
  bool _syncInProgress = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void dispose() {
    _connectivitySub?.cancel();
    _statusController.close();
  }

  /// Start watching connectivity changes and auto-syncing on reconnection.
  Future<void> startWatching() async {
    final currentlyOnline = await _networkInfo.isConnected;
    _wasOffline = !currentlyOnline;

    _connectivitySub = _networkInfo.onStatusChange.listen((status) async {
      if (status == ConnectivityStatus.online && _wasOffline) {
        // Wait for connection to stabilise before hammering the server.
        await Future<void>.delayed(const Duration(seconds: 2));
        final settings = await _repo.loadSettings();
        if (settings.autoSyncEnabled) {
          await triggerSync(syncType: 'auto');
        }
        _wasOffline = false;
      } else if (status == ConnectivityStatus.offline) {
        _wasOffline = true;
        _emit(SyncStatus.idle);
      }
    });
  }

  // ── Manual / automatic sync ───────────────────────────────────────────────

  /// Triggers a full bidirectional sync. Returns a [SyncResult].
  Future<SyncResult> triggerSync({String syncType = 'manual'}) async {
    if (_syncInProgress) {
      return SyncResult.failed('Sync already in progress');
    }

    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return SyncResult.failed('No internet connection');
    }

    _syncInProgress = true;
    _emit(SyncStatus.syncing);

    try {
      final result = await _repo.fullSync();
      _emit(result.status);
      return result;
    } catch (e) {
      _emit(SyncStatus.failed);
      return SyncResult.failed(e.toString());
    } finally {
      _syncInProgress = false;
    }
  }

  // ── Queue helpers (called from feature layers) ────────────────────────────

  Future<void> enqueueCreate({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) =>
      _enqueue(
        operationType: OperationType.createRecord,
        endpoint:      endpoint,
        payload:       payload,
      );

  Future<void> enqueueUpdate({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) =>
      _enqueue(
        operationType: OperationType.updateRecord,
        endpoint:      endpoint,
        payload:       payload,
      );

  Future<void> enqueueSaveAssessment(Map<String, dynamic> assessmentPayload) =>
      _enqueue(
        operationType: OperationType.saveAssessment,
        endpoint:      '/api/v1/offline/upload/',
        payload:       assessmentPayload,
      );

  Future<void> enqueueSaveChatMessage(Map<String, dynamic> chatPayload) =>
      _enqueue(
        operationType: OperationType.saveChatMessage,
        endpoint:      '/api/v1/offline/upload/',
        payload:       chatPayload,
      );

  Future<void> _enqueue({
    required OperationType operationType,
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueItemModel.create(
      id:            _uuid.v4(),
      operationType: operationType,
      endpoint:      endpoint,
      payloadMap:    payload,
    );
    await _repo.enqueue(item);
  }

  // ── Cache helper ──────────────────────────────────────────────────────────

  /// Store an API response keyed by [cacheKey] with [ttlHours] TTL.
  Future<void> cacheResponse({
    required String cacheKey,
    required String responseBody,
    int ttlHours = 6,
  }) async {
    final now = DateTime.now();
    await LocalDbService.instance.cacheApiResponseEntry(
      _InlineCachedApiResponse(
        id:        _uuid.v4(),
        cacheKey:  cacheKey,
        response:  responseBody,
        createdAt: now,
        expiresAt: now.add(Duration(hours: ttlHours)),
      ),
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _emit(SyncStatus s) {
    _status = s;
    if (!_statusController.isClosed) _statusController.add(s);
  }
}

// ---------------------------------------------------------------------------
// Tiny concrete subclass used only inside this file.
// ---------------------------------------------------------------------------
class _InlineCachedApiResponse extends CachedApiResponse {
  const _InlineCachedApiResponse({
    required super.id,
    required super.cacheKey,
    required super.response,
    required super.createdAt,
    required super.expiresAt,
  });
}
