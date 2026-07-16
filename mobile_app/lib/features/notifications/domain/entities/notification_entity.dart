import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String ntype; // info | warning | success | alert
  final String? module;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.ntype,
    this.module,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  bool get isWarning => ntype == 'warning';
  bool get isAlert   => ntype == 'alert';
  bool get isSuccess => ntype == 'success';

  @override
  List<Object?> get props => [id, isRead, createdAt];
}
