import '../../domain/entities/emergency_contact.dart';

class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.relation,
    super.isPrimary,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      // Accept both snake_case (backend) and camelCase (legacy)
      phoneNumber: (json['phone_number'] ?? json['phoneNumber']) as String,
      relation: json['relation'] as String? ?? '',
      isPrimary: (json['is_primary'] ?? json['isPrimary']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relation': relation,
      'is_primary': isPrimary,
    };
  }
}
