import '../../domain/entities/clinic.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/entities/route.dart';

enum NearbyHealthcareStatus { initial, loading, ready, routing, error }

enum HealthcareFacilityType { hospitals, clinics, pharmacies }

class NearbyHealthcareState {
  final NearbyHealthcareStatus status;
  final Location? currentLocation;
  final List<Hospital> hospitals;
  final List<Clinic> clinics;
  final List<Pharmacy> pharmacies;
  final HealthcareRoute? selectedRoute;
  final HealthcareFacilityType selectedType;
  final String? errorMessage;

  const NearbyHealthcareState({
    this.status = NearbyHealthcareStatus.initial,
    this.currentLocation,
    this.hospitals = const [],
    this.clinics = const [],
    this.pharmacies = const [],
    this.selectedRoute,
    this.selectedType = HealthcareFacilityType.hospitals,
    this.errorMessage,
  });

  bool get isLoading {
    return status == NearbyHealthcareStatus.initial ||
        status == NearbyHealthcareStatus.loading;
  }

  bool get isRouting => status == NearbyHealthcareStatus.routing;

  int get totalFacilities {
    return hospitals.length + clinics.length + pharmacies.length;
  }

  NearbyHealthcareState copyWith({
    NearbyHealthcareStatus? status,
    Location? currentLocation,
    List<Hospital>? hospitals,
    List<Clinic>? clinics,
    List<Pharmacy>? pharmacies,
    HealthcareRoute? selectedRoute,
    HealthcareFacilityType? selectedType,
    String? errorMessage,
    bool clearRoute = false,
    bool clearError = false,
  }) {
    return NearbyHealthcareState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      hospitals: hospitals ?? this.hospitals,
      clinics: clinics ?? this.clinics,
      pharmacies: pharmacies ?? this.pharmacies,
      selectedRoute: clearRoute ? null : selectedRoute ?? this.selectedRoute,
      selectedType: selectedType ?? this.selectedType,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
