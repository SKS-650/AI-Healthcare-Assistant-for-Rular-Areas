import '../../domain/entities/location.dart';
import '../../domain/entities/route.dart';

class HealthcareRouteModel extends HealthcareRoute {
  const HealthcareRouteModel({
    required super.id,
    required super.origin,
    required super.destination,
    required super.distanceKm,
    required super.travelTimeMinutes,
    required super.mode,
    required super.steps,
  });

  HealthcareRouteModel copyWith({
    String? id,
    Location? origin,
    Location? destination,
    double? distanceKm,
    int? travelTimeMinutes,
    String? mode,
    List<String>? steps,
  }) {
    return HealthcareRouteModel(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      distanceKm: distanceKm ?? this.distanceKm,
      travelTimeMinutes: travelTimeMinutes ?? this.travelTimeMinutes,
      mode: mode ?? this.mode,
      steps: steps ?? this.steps,
    );
  }
}
