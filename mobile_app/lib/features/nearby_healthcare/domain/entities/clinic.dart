import 'location.dart';

class Clinic {
  final String id;
  final String name;
  final String specialty;
  final Location location;
  final double distanceKm;
  final int travelTimeMinutes;
  final double rating;
  final String phoneNumber;
  final bool isOpen;

  const Clinic({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.distanceKm,
    required this.travelTimeMinutes,
    required this.rating,
    required this.phoneNumber,
    required this.isOpen,
  });
}
