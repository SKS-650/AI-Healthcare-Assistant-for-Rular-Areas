import 'location.dart';

class Pharmacy {
  final String id;
  final String name;
  final Location location;
  final double distanceKm;
  final int travelTimeMinutes;
  final double rating;
  final String phoneNumber;
  final bool isOpen;
  final bool hasDelivery;
  final List<String> availableServices;

  const Pharmacy({
    required this.id,
    required this.name,
    required this.location,
    required this.distanceKm,
    required this.travelTimeMinutes,
    required this.rating,
    required this.phoneNumber,
    required this.isOpen,
    required this.hasDelivery,
    required this.availableServices,
  });
}
