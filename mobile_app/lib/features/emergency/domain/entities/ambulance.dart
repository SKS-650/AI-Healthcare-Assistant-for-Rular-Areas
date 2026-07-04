class Ambulance {
  final String id;
  final String providerName;
  final String driverName;
  final String phoneNumber;
  final double distanceKm;
  final int etaMinutes;
  final bool available;

  const Ambulance({
    required this.id,
    required this.providerName,
    required this.driverName,
    required this.phoneNumber,
    required this.distanceKm,
    required this.etaMinutes,
    this.available = true,
  });
}
