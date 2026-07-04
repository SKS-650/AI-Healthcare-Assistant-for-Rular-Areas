import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.address,
    required super.distanceKm,
    required super.contactNumber,
    required super.isOpen,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      contactNumber: json['contactNumber'] as String,
      isOpen: json['isOpen'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distanceKm': distanceKm,
      'contactNumber': contactNumber,
      'isOpen': isOpen,
    };
  }
}
