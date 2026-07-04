import '../../domain/entities/emergency_history.dart';
import 'emergency_event_model.dart';

class EmergencyHistoryModel extends EmergencyHistory {
  const EmergencyHistoryModel({
    required super.id,
    required super.event,
    required super.actionTaken,
    required super.savedAt,
  });

  factory EmergencyHistoryModel.fromJson(Map<String, dynamic> json) {
    return EmergencyHistoryModel(
      id: json['id'] as String,
      event: EmergencyEventModel.fromJson(
        json['event'] as Map<String, dynamic>,
      ),
      actionTaken: json['actionTaken'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  factory EmergencyHistoryModel.fromEntity(EmergencyHistory history) {
    return EmergencyHistoryModel(
      id: history.id,
      event: history.event,
      actionTaken: history.actionTaken,
      savedAt: history.savedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': EmergencyEventModel.fromEntity(event).toJson(),
      'actionTaken': actionTaken,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
