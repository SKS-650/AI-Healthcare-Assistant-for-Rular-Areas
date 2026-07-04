import '../../domain/entities/pharmacy.dart';

class PharmacyModel extends Pharmacy {
  const PharmacyModel({
    required super.id,
    required super.name,
    required super.location,
    required super.distanceKm,
    required super.travelTimeMinutes,
    required super.rating,
    required super.phoneNumber,
    required super.isOpen,
    required super.hasDelivery,
    required super.availableServices,
  });
}
