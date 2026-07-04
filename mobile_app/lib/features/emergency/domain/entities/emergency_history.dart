import 'emergency_event.dart';

class EmergencyHistory {
  final String id;
  final EmergencyEvent event;
  final String actionTaken;
  final DateTime savedAt;

  const EmergencyHistory({
    required this.id,
    required this.event,
    required this.actionTaken,
    required this.savedAt,
  });
}
