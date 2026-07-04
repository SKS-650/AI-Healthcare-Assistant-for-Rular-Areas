import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/emergency_repository_impl.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../domain/usecases/get_emergency_contacts.dart';
import '../../domain/usecases/get_emergency_data.dart';
import '../../domain/usecases/get_first_aid.dart';
import '../../domain/usecases/get_nearby_ambulances.dart';
import '../../domain/usecases/get_nearby_hospitals.dart';
import '../../domain/usecases/save_emergency_history.dart';
import '../controllers/emergency_controller.dart';
import '../controllers/emergency_state.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  return EmergencyRepositoryImpl();
});

final emergencyControllerProvider =
    StateNotifierProvider<EmergencyController, EmergencyState>((ref) {
      final repository = ref.watch(emergencyRepositoryProvider);
      return EmergencyController(
        getEmergencyData: GetEmergencyData(repository),
        getFirstAid: GetFirstAid(repository),
        getNearbyHospitals: GetNearbyHospitals(repository),
        getNearbyAmbulances: GetNearbyAmbulances(repository),
        getEmergencyContacts: GetEmergencyContacts(repository),
        saveEmergencyHistory: SaveEmergencyHistory(repository),
        repository: repository,
      );
    });
