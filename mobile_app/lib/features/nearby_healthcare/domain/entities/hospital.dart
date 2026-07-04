import 'location.dart';

class Hospital {
  final String id;
  final String name;
  final String type;
  final Location location;
  final double distanceKm;
  final int travelTimeMinutes;
  final double rating;
  final String phoneNumber;
  final bool isOpen;
  final bool hasEmergency;
  final List<String> services;

  const Hospital({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.distanceKm,
    required this.travelTimeMinutes,
    required this.rating,
    required this.phoneNumber,
    required this.isOpen,
    required this.hasEmergency,
    required this.services,
  });
}
