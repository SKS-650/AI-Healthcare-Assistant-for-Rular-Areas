import '../../domain/entities/clinic.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/entities/route.dart';
import '../../domain/repositories/nearby_healthcare_repository.dart';
import '../datasources/nearby_healthcare_dummy_data.dart';
import '../models/location_model.dart';

class NearbyHealthcareRepositoryImpl implements NearbyHealthcareRepository {
  @override
  Future<List<Hospital>> getNearbyHospitals() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return NearbyHealthcareDummyData.hospitals;
  }

  @override
  Future<List<Clinic>> getNearbyClinics() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return NearbyHealthcareDummyData.clinics;
  }

  @override
  Future<List<Pharmacy>> getNearbyPharmacies() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return NearbyHealthcareDummyData.pharmacies;
  }

  @override
  Future<Location> getLocation() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return NearbyHealthcareDummyData.currentLocation;
  }

  @override
  Future<HealthcareRoute> getRoute(Location destination) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final allFacilities = [
      ...NearbyHealthcareDummyData.hospitals.map(
        (facility) => (
          location: facility.location,
          distance: facility.distanceKm,
          minutes: facility.travelTimeMinutes,
        ),
      ),
      ...NearbyHealthcareDummyData.clinics.map(
        (facility) => (
          location: facility.location,
          distance: facility.distanceKm,
          minutes: facility.travelTimeMinutes,
        ),
      ),
      ...NearbyHealthcareDummyData.pharmacies.map(
        (facility) => (
          location: facility.location,
          distance: facility.distanceKm,
          minutes: facility.travelTimeMinutes,
        ),
      ),
    ];

    final match = allFacilities.firstWhere(
      (facility) =>
          facility.location.latitude == destination.latitude &&
          facility.location.longitude == destination.longitude,
      orElse: () => (location: destination, distance: 2.0, minutes: 12),
    );

    return NearbyHealthcareDummyData.routeTo(
      destination: LocationModel(
        latitude: match.location.latitude,
        longitude: match.location.longitude,
        address: match.location.address,
        label: match.location.label,
      ),
      distanceKm: match.distance,
      minutes: match.minutes,
    );
  }
}
