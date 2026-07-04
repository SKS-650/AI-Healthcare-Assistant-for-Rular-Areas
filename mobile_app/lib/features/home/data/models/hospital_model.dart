// lib/features/home/data/models/hospital_model.dart
import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.distance,
    required super.address,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      distance: (json['distance'] as num).toDouble(),
      address: json['address'] as String,
    );
  }
}