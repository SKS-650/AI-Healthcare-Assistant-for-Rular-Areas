import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/nearby_healthcare_repository_impl.dart';
import '../../domain/repositories/nearby_healthcare_repository.dart';
import '../../domain/usecases/get_location.dart';
import '../../domain/usecases/get_nearby_clinics.dart';
import '../../domain/usecases/get_nearby_hospitals.dart';
import '../../domain/usecases/get_nearby_pharmacies.dart';
import '../../domain/usecases/get_route.dart';
import '../controllers/nearby_healthcare_controller.dart';
import '../controllers/nearby_healthcare_state.dart';

final nearbyHealthcareRepositoryProvider = Provider<NearbyHealthcareRepository>(
  (ref) {
    return NearbyHealthcareRepositoryImpl();
  },
);

final nearbyHealthcareControllerProvider =
    StateNotifierProvider<NearbyHealthcareController, NearbyHealthcareState>((
      ref,
    ) {
      final repository = ref.watch(nearbyHealthcareRepositoryProvider);
      return NearbyHealthcareController(
        nearbyHospitals: GetNearbyHospitals(repository),
        nearbyClinics: GetNearbyClinics(repository),
        nearbyPharmacies: GetNearbyPharmacies(repository),
        location: GetLocation(repository),
        route: GetRoute(repository),
      );
    });
