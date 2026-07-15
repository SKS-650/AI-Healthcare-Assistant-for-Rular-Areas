import '../enums/offline_enums.dart';

/// A record of a completed synchronisation attempt.
class SyncHistoryEntry {
  const SyncHistoryEntry({
    required this.id,
    required this.syncType,
    required this.status,
    required this.syncedItems,
    required this.failedItems,
    required this.createdAt,
    this.details,
    this.durationMs,
  });

  final String id;

  /// e.g. 'full', 'partial', 'upload', 'download'
  final String syncType;

  final SyncStatus status;
  final int syncedItems;
  final int failedItems;
  final DateTime createdAt;
  final String? details;
  final int? durationMs;
}
