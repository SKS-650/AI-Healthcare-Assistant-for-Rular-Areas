import 'location.dart';

class HealthcareRoute {
  final String id;
  final Location origin;
  final Location destination;
  final double distanceKm;
  final int travelTimeMinutes;
  final String mode;
  final List<String> steps;

  const HealthcareRoute({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.travelTimeMinutes,
    required this.mode,
    required this.steps,
  });
}
