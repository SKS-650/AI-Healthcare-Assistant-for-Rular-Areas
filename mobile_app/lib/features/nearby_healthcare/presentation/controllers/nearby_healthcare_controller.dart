// ignore_for_file: prefer_initializing_formals

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/clinic.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/usecases/get_location.dart';
import '../../domain/usecases/get_nearby_clinics.dart';
import '../../domain/usecases/get_nearby_hospitals.dart';
import '../../domain/usecases/get_nearby_pharmacies.dart';
import '../../domain/usecases/get_route.dart';
import 'nearby_healthcare_state.dart';

class NearbyHealthcareController extends StateNotifier<NearbyHealthcareState> {
  final GetNearbyHospitals _getNearbyHospitals;
  final GetNearbyClinics _getNearbyClinics;
  final GetNearbyPharmacies _getNearbyPharmacies;
  final GetLocation _getLocation;
  final GetRoute _getRoute;

  NearbyHealthcareController({
    required GetNearbyHospitals nearbyHospitals,
    required GetNearbyClinics nearbyClinics,
    required GetNearbyPharmacies nearbyPharmacies,
    required GetLocation location,
    required GetRoute route,
  }) : _getNearbyHospitals = nearbyHospitals,
       _getNearbyClinics = nearbyClinics,
       _getNearbyPharmacies = nearbyPharmacies,
       _getLocation = location,
       _getRoute = route,
       super(const NearbyHealthcareState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(
      status: NearbyHealthcareStatus.loading,
      clearError: true,
    );
    try {
      final results = await Future.wait([
        _getLocation(),
        _getNearbyHospitals(),
        _getNearbyClinics(),
        _getNearbyPharmacies(),
      ]);

      state = state.copyWith(
        status: NearbyHealthcareStatus.ready,
        currentLocation: results[0] as Location,
        hospitals: results[1] as List<Hospital>,
        clinics: results[2] as List<Clinic>,
        pharmacies: results[3] as List<Pharmacy>,
      );
    } catch (_) {
      state = state.copyWith(
        status: NearbyHealthcareStatus.error,
        errorMessage: 'Unable to load nearby healthcare facilities.',
      );
    }
  }

  void selectType(HealthcareFacilityType type) {
    state = state.copyWith(selectedType: type);
  }

  Future<void> loadRoute(Location destination) async {
    state = state.copyWith(
      status: NearbyHealthcareStatus.routing,
      clearError: true,
    );
    try {
      final route = await _getRoute(destination);
      state = state.copyWith(
        status: NearbyHealthcareStatus.ready,
        selectedRoute: route,
      );
    } catch (_) {
      state = state.copyWith(
        status: NearbyHealthcareStatus.error,
        errorMessage: 'Unable to calculate route.',
      );
    }
  }

  void clearRoute() {
    state = state.copyWith(clearRoute: true);
  }
}
