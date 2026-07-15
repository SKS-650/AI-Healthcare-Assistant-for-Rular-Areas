import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';
import '../../data/repositories/emergency_repository_impl.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../domain/usecases/get_emergency_contacts.dart';
import '../../domain/usecases/get_emergency_data.dart';
import '../../domain/usecases/get_first_aid.dart';
import '../../domain/usecases/get_nearby_ambulances.dart';
import '../../domain/usecases/get_nearby_hospitals.dart';
import '../../domain/usecases/run_assessment.dart';
import '../../domain/usecases/save_emergency_history.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/assessment_state.dart';
import '../controllers/emergency_controller.dart';
import '../controllers/emergency_state.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  if (authRepo is AuthenticationRepositoryImpl) {
    return EmergencyRepositoryImpl.withAuth(authRepo);
  }
  return EmergencyRepositoryImpl();
});

// ── Use-cases ─────────────────────────────────────────────────────────────────

final _runAssessmentProvider = Provider<RunAssessment>(
  (ref) => RunAssessment(ref.watch(emergencyRepositoryProvider)),
);

// ── Emergency Controller ──────────────────────────────────────────────────────

final emergencyControllerProvider =
    StateNotifierProvider<EmergencyController, EmergencyState>((ref) {
  final repository = ref.watch(emergencyRepositoryProvider);
  return EmergencyController(
    getEmergencyData:     GetEmergencyData(repository),
    getFirstAid:          GetFirstAid(repository),
    getNearbyHospitals:   GetNearbyHospitals(repository),
    getNearbyAmbulances:  GetNearbyAmbulances(repository),
    getEmergencyContacts: GetEmergencyContacts(repository),
    saveEmergencyHistory: SaveEmergencyHistory(repository),
    repository:           repository,
  );
});

// ── Assessment Controller ─────────────────────────────────────────────────────

final assessmentControllerProvider =
    StateNotifierProvider<AssessmentController, AssessmentState>((ref) {
  return AssessmentController(
    runAssessment: ref.watch(_runAssessmentProvider),
  );
});
