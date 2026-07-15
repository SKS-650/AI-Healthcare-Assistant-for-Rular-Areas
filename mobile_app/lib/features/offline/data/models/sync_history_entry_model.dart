import '../../domain/entities/sync_history_entry.dart';
import '../../domain/enums/offline_enums.dart';

class SyncHistoryEntryModel extends SyncHistoryEntry {
  const SyncHistoryEntryModel({
    required super.id,
    required super.syncType,
    required super.status,
    required super.syncedItems,
    required super.failedItems,
    required super.createdAt,
    super.details,
    super.durationMs,
  });

  factory SyncHistoryEntryModel.fromJson(Map<String, dynamic> json) =>
      SyncHistoryEntryModel(
        id:          json['id'] as String,
        syncType:    json['sync_type'] as String,
        status:      SyncStatus.values.byName(json['status'] as String),
        syncedItems: json['synced_items'] as int,
        failedItems: json['failed_items'] as int,
        createdAt:   DateTime.parse(json['created_at'] as String),
        details:     json['details'] as String?,
        durationMs:  json['duration_ms'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id':           id,
        'sync_type':    syncType,
        'status':       status.name,
        'synced_items': syncedItems,
        'failed_items': failedItems,
        'created_at':   createdAt.toIso8601String(),
        'details':      details,
        'duration_ms':  durationMs,
      };
}
