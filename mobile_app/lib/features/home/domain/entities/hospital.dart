// lib/features/home/domain/entities/hospital.dart
class Hospital {
  final String id;
  final String name;
  final String address;
  final double distance; // km
  final String? phone;
  final bool emergencyAvailable;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    this.phone,
    this.emergencyAvailable = true,
  });
}
