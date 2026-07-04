import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.type,
    required super.location,
    required super.distanceKm,
    required super.travelTimeMinutes,
    required super.rating,
    required super.phoneNumber,
    required super.isOpen,
    required super.hasEmergency,
    required super.services,
  });
}
