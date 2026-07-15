import '../entities/ambulance.dart';
import '../entities/emergency_assessment.dart';
import '../entities/emergency_contact.dart';
import '../entities/emergency_event.dart';
import '../entities/emergency_history.dart';
import '../entities/emergency_type.dart';
import '../entities/first_aid.dart';
import '../entities/hospital.dart';

class EmergencyData {
  final List<EmergencyType> types;
  final List<Hospital> hospitals;
  final List<Ambulance> ambulances;
  final List<EmergencyContact> contacts;
  final List<FirstAid> firstAidGuides;
  final List<EmergencyHistory> history;

  const EmergencyData({
    required this.types,
    required this.hospitals,
    required this.ambulances,
    required this.contacts,
    required this.firstAidGuides,
    required this.history,
  });
}

abstract class EmergencyRepository {
  // ── Existing ─────────────────────────────────────────────────────────────
  Future<EmergencyData> getEmergencyData();
  Future<List<FirstAid>> getFirstAid();
  Future<List<Hospital>> getNearbyHospitals();
  Future<List<Ambulance>> getNearbyAmbulances();
  Future<List<EmergencyContact>> getEmergencyContacts();
  Future<List<EmergencyHistory>> getEmergencyHistory();
  Future<EmergencyEvent> detectEmergency(String description);
  Future<EmergencyEvent> triggerSos(EmergencyType type);
  Future<void> saveEmergencyHistory(EmergencyHistory history);

  // ── AI Assessment (new) ───────────────────────────────────────────────────
  /// Run the full AI triage pipeline via the backend API.
  Future<EmergencyAssessment> runAssessment(AssessmentInput input);

  /// Fetch past assessments for the authenticated user.
  Future<List<EmergencyAssessment>> getAssessmentHistory({
    int limit = 20,
    int offset = 0,
  });

  /// Fetch a single assessment by ID.
  Future<EmergencyAssessment> getAssessmentById(String id);

  // ── Emergency Contacts CRUD (new) ─────────────────────────────────────────
  Future<EmergencyContact> createContact({
    required String name,
    required String phoneNumber,
    required String relation,
    bool isPrimary = false,
  });

  Future<EmergencyContact> updateContact({
    required String contactId,
    String? name,
    String? phoneNumber,
    String? relation,
    bool? isPrimary,
  });

  Future<void> deleteContact(String contactId);

  // ── SOS (new) ─────────────────────────────────────────────────────────────
  Future<void> triggerSosAlert({
    required String emergencyType,
    double? locationLat,
    double? locationLng,
    String? locationText,
    String? assessmentId,
  });
}
