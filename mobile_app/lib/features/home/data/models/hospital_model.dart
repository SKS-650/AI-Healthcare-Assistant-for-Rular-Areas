// lib/features/home/data/models/hospital_model.dart
import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.address,
    required super.distance,
    super.phone,
    super.emergencyAvailable,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      distance: (json['distance'] as num).toDouble(),
      phone: json['phone'] as String?,
      emergencyAvailable: json['emergency_available'] as bool? ?? true,
    );
  }
}
