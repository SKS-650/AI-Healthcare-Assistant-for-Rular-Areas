import '../../domain/entities/ambulance.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/entities/emergency_history.dart';
import '../../domain/entities/emergency_type.dart';
import '../../domain/entities/first_aid.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_dummy_data.dart';
import '../models/emergency_event_model.dart';
import '../models/emergency_history_model.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final List<EmergencyHistory> _history = EmergencyDummyData.initialHistory();

  @override
  Future<EmergencyData> getEmergencyData() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return EmergencyData(
      types: EmergencyDummyData.emergencyTypes,
      hospitals: EmergencyDummyData.hospitals,
      ambulances: EmergencyDummyData.ambulances,
      contacts: EmergencyDummyData.contacts,
      firstAidGuides: EmergencyDummyData.firstAidGuides,
      history: List.unmodifiable(_history),
    );
  }

  @override
  Future<List<EmergencyHistory>> getEmergencyHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_history);
  }

  @override
  Future<List<FirstAid>> getFirstAid() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return EmergencyDummyData.firstAidGuides;
  }

  @override
  Future<List<Ambulance>> getNearbyAmbulances() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return EmergencyDummyData.ambulances;
  }

  @override
  Future<List<Hospital>> getNearbyHospitals() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return EmergencyDummyData.hospitals;
  }

  @override
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return EmergencyDummyData.contacts;
  }

  @override
  Future<EmergencyEvent> detectEmergency(String description) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final lower = description.toLowerCase();
    final EmergencyType type;
    if (lower.contains('breath') || lower.contains('chok')) {
      type = EmergencyDummyData.emergencyTypes[2];
    } else if (lower.contains('blood') ||
        lower.contains('injur') ||
        lower.contains('accident')) {
      type = EmergencyDummyData.emergencyTypes[1];
    } else if (lower.contains('allerg') || lower.contains('swelling')) {
      type = EmergencyDummyData.emergencyTypes[3];
    } else {
      type = EmergencyDummyData.emergencyTypes.first;
    }
    return EmergencyEventModel(
      id: 'detected-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      status: 'Detected',
      createdAt: DateTime.now(),
      location: 'Current location',
    );
  }

  @override
  Future<EmergencyEvent> triggerSos(EmergencyType type) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final event = EmergencyEventModel(
      id: 'sos-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      status: 'SOS sent',
      createdAt: DateTime.now(),
      location: 'Current location',
      sosSent: true,
    );
    await saveEmergencyHistory(
      EmergencyHistoryModel(
        id: 'history-${DateTime.now().millisecondsSinceEpoch}',
        event: event,
        actionTaken:
            'SOS alert sent to emergency contacts and nearby responders.',
        savedAt: DateTime.now(),
      ),
    );
    return event;
  }

  @override
  Future<void> saveEmergencyHistory(EmergencyHistory history) async {
    _history.insert(0, EmergencyHistoryModel.fromEntity(history));
  }
}
