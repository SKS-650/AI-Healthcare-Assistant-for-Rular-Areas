import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.ntype,
    super.module,
    super.referenceId,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id:          json['id'] as String,
        userId:      json['user_id'] as String? ?? '',
        title:       json['title'] as String,
        body:        json['body'] as String,
        ntype:       json['ntype'] as String? ?? 'info',
        module:      json['module'] as String?,
        referenceId: json['reference_id'] as String?,
        isRead:      json['is_read'] as bool? ?? false,
        createdAt:   DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id':           id,
        'user_id':      userId,
        'title':        title,
        'body':         body,
        'ntype':        ntype,
        'module':       module,
        'reference_id': referenceId,
        'is_read':      isRead,
        'created_at':   createdAt.toIso8601String(),
      };
}
