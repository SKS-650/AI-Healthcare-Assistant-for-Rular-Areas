import 'emergency_type.dart';

class EmergencyEvent {
  final String id;
  final EmergencyType type;
  final String status;
  final DateTime createdAt;
  final String location;
  final bool sosSent;

  const EmergencyEvent({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.location,
    this.sosSent = false,
  });
}
