import '../enums/offline_enums.dart';

/// A single pending operation waiting to be synced to the server.
class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.operationType,
    required this.endpoint,
    required this.payload,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    required this.updatedAt,
    this.errorMessage,
  });

  final String id;
  final OperationType operationType;
  final String endpoint;

  /// JSON-encoded request body.
  final String payload;

  final QueueItemStatus status;
  final int retryCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? errorMessage;

  static const int maxRetries = 3;

  bool get canRetry => retryCount < maxRetries && !status.isCompleted;

  SyncQueueItem copyWith({
    QueueItemStatus? status,
    int? retryCount,
    DateTime? updatedAt,
    String? errorMessage,
  }) {
    return SyncQueueItem(
      id:            id,
      operationType: operationType,
      endpoint:      endpoint,
      payload:       payload,
      status:        status        ?? this.status,
      retryCount:    retryCount    ?? this.retryCount,
      createdAt:     createdAt,
      updatedAt:     updatedAt     ?? this.updatedAt,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SyncQueueItem && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
