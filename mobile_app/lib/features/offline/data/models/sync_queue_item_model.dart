import 'dart:convert';

import '../../domain/entities/sync_queue_item.dart';
import '../../domain/enums/offline_enums.dart';

class SyncQueueItemModel extends SyncQueueItem {
  const SyncQueueItemModel({
    required super.id,
    required super.operationType,
    required super.endpoint,
    required super.payload,
    required super.status,
    required super.retryCount,
    required super.createdAt,
    required super.updatedAt,
    super.errorMessage,
  });

  factory SyncQueueItemModel.fromJson(Map<String, dynamic> json) {
    return SyncQueueItemModel(
      id:            json['id'] as String,
      operationType: OperationType.values.byName(json['operation_type'] as String),
      endpoint:      json['endpoint'] as String,
      payload:       json['payload'] as String,
      status:        QueueItemStatus.values.byName(json['status'] as String),
      retryCount:    json['retry_count'] as int,
      createdAt:     DateTime.parse(json['created_at'] as String),
      updatedAt:     DateTime.parse(json['updated_at'] as String),
      errorMessage:  json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':             id,
        'operation_type': operationType.name,
        'endpoint':       endpoint,
        'payload':        payload,
        'status':         status.name,
        'retry_count':    retryCount,
        'created_at':     createdAt.toIso8601String(),
        'updated_at':     updatedAt.toIso8601String(),
        'error_message':  errorMessage,
      };

  /// Create a new pending item from raw parts.
  factory SyncQueueItemModel.create({
    required String id,
    required OperationType operationType,
    required String endpoint,
    required Map<String, dynamic> payloadMap,
  }) {
    final now = DateTime.now();
    return SyncQueueItemModel(
      id:            id,
      operationType: operationType,
      endpoint:      endpoint,
      payload:       jsonEncode(payloadMap),
      status:        QueueItemStatus.pending,
      retryCount:    0,
      createdAt:     now,
      updatedAt:     now,
    );
  }

  SyncQueueItemModel withStatus(QueueItemStatus newStatus, {String? error}) =>
      SyncQueueItemModel(
        id:            id,
        operationType: operationType,
        endpoint:      endpoint,
        payload:       payload,
        status:        newStatus,
        retryCount:    newStatus == QueueItemStatus.failed ? retryCount + 1 : retryCount,
        createdAt:     createdAt,
        updatedAt:     DateTime.now(),
        errorMessage:  error ?? errorMessage,
      );
}
