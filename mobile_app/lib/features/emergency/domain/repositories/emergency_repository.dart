import '../entities/ambulance.dart';
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
  Future<EmergencyData> getEmergencyData();
  Future<List<FirstAid>> getFirstAid();
  Future<List<Hospital>> getNearbyHospitals();
  Future<List<Ambulance>> getNearbyAmbulances();
  Future<List<EmergencyContact>> getEmergencyContacts();
  Future<List<EmergencyHistory>> getEmergencyHistory();
  Future<EmergencyEvent> detectEmergency(String description);
  Future<EmergencyEvent> triggerSos(EmergencyType type);
  Future<void> saveEmergencyHistory(EmergencyHistory history);
}
