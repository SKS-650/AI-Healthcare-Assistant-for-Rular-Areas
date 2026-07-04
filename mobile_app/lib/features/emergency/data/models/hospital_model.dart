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
      distanceKm: (json['distanceKm'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String,
      emergencyAvailable: json['emergencyAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distanceKm': distanceKm,
      'phoneNumber': phoneNumber,
      'emergencyAvailable': emergencyAvailable,
    };
  }
}
