import '../../domain/entities/clinic.dart';

class ClinicModel extends Clinic {
  const ClinicModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.location,
    required super.distanceKm,
    required super.travelTimeMinutes,
    required super.rating,
    required super.phoneNumber,
    required super.isOpen,
  });
}
