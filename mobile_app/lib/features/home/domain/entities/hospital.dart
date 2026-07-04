// lib/features/home/domain/entities/hospital.dart
class Hospital {
  final String id;
  final String name;
  final double distance; // In km
  final String address;

  const Hospital({
    required this.id,
    required this.name,
    required this.distance,
    required this.address,
  });
}