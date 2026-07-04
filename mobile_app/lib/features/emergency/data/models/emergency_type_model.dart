import '../../domain/entities/emergency_type.dart';

class EmergencyTypeModel extends EmergencyType {
  const EmergencyTypeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.severity,
  });

  factory EmergencyTypeModel.fromJson(Map<String, dynamic> json) {
    return EmergencyTypeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity,
    };
  }
}
