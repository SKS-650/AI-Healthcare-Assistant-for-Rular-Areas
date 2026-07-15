import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.address,
    required super.distanceKm,
    required super.phoneNumber,
    super.emergencyAvailable,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      // Accept both snake_case (backend) and camelCase (legacy dummy data)
      distanceKm: ((json['distance_km'] ?? json['distanceKm']) as num).toDouble(),
      phoneNumber: (json['phone_number'] ?? json['phoneNumber']) as String,
      emergencyAvailable:
          (json['emergency_available'] ?? json['emergencyAvailable']) as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distance_km': distanceKm,
      'phone_number': phoneNumber,
      'emergency_available': emergencyAvailable,
    };
  }
}
