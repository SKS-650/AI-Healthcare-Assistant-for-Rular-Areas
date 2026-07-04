import '../../domain/entities/emergency_event.dart';
import '../../domain/entities/emergency_type.dart';
import 'emergency_type_model.dart';

class EmergencyEventModel extends EmergencyEvent {
  const EmergencyEventModel({
    required super.id,
    required super.type,
    required super.status,
    required super.createdAt,
    required super.location,
    super.sosSent,
  });

  factory EmergencyEventModel.fromJson(Map<String, dynamic> json) {
    return EmergencyEventModel(
      id: json['id'] as String,
      type: EmergencyTypeModel.fromJson(json['type'] as Map<String, dynamic>),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      location: json['location'] as String,
      sosSent: json['sosSent'] as bool? ?? false,
    );
  }

  factory EmergencyEventModel.fromEntity(EmergencyEvent event) {
    return EmergencyEventModel(
      id: event.id,
      type: event.type,
      status: event.status,
      createdAt: event.createdAt,
      location: event.location,
      sosSent: event.sosSent,
    );
  }

  Map<String, dynamic> toJson() {
    final currentType = type;
    return {
      'id': id,
      'type': EmergencyTypeModel(
        id: currentType.id,
        title: currentType.title,
        description: currentType.description,
        severity: currentType.severity,
      ).toJson(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'location': location,
      'sosSent': sosSent,
    };
  }

  EmergencyEventModel copyWith({
    String? id,
    EmergencyType? type,
    String? status,
    DateTime? createdAt,
    String? location,
    bool? sosSent,
  }) {
    return EmergencyEventModel(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      sosSent: sosSent ?? this.sosSent,
    );
  }
}
