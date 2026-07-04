class Hospital {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final String contactNumber;
  final bool isOpen;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.contactNumber,
    required this.isOpen,
  });
}
