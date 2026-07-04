class Hospital {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final String phoneNumber;
  final bool emergencyAvailable;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.phoneNumber,
    this.emergencyAvailable = true,
  });
}
