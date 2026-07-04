// ignore_for_file: prefer_initializing_formals

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/emergency_event.dart';
import '../../domain/entities/emergency_history.dart';
import '../../domain/entities/emergency_type.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../domain/usecases/get_emergency_contacts.dart';
import '../../domain/usecases/get_emergency_data.dart';
import '../../domain/usecases/get_first_aid.dart';
import '../../domain/usecases/get_nearby_ambulances.dart';
import '../../domain/usecases/get_nearby_hospitals.dart';
import '../../domain/usecases/save_emergency_history.dart';
import 'emergency_state.dart';

class EmergencyController extends StateNotifier<EmergencyState> {
  final GetEmergencyData _getEmergencyData;
  final GetFirstAid _getFirstAid;
  final GetNearbyHospitals _getNearbyHospitals;
  final GetNearbyAmbulances _getNearbyAmbulances;
  final GetEmergencyContacts _getEmergencyContacts;
  final SaveEmergencyHistory _saveEmergencyHistory;
  final EmergencyRepository _repository;

  EmergencyController({
    required GetEmergencyData getEmergencyData,
    required GetFirstAid getFirstAid,
    required GetNearbyHospitals getNearbyHospitals,
    required GetNearbyAmbulances getNearbyAmbulances,
    required GetEmergencyContacts getEmergencyContacts,
    required SaveEmergencyHistory saveEmergencyHistory,
    required EmergencyRepository repository,
  }) : _getEmergencyData = getEmergencyData,
       _getFirstAid = getFirstAid,
       _getNearbyHospitals = getNearbyHospitals,
       _getNearbyAmbulances = getNearbyAmbulances,
       _getEmergencyContacts = getEmergencyContacts,
       _saveEmergencyHistory = saveEmergencyHistory,
       _repository = repository,
       super(const EmergencyState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: EmergencyStatus.loading, clearError: true);
    try {
      final data = await _getEmergencyData();
      state = state.copyWith(
        status: EmergencyStatus.ready,
        types: data.types,
        hospitals: data.hospitals,
        ambulances: data.ambulances,
        contacts: data.contacts,
        firstAidGuides: data.firstAidGuides,
        history: data.history,
      );
    } catch (_) {
      state = state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: 'Unable to load emergency support.',
      );
    }
  }

  Future<void> refreshHospitals() async {
    state = state.copyWith(hospitals: await _getNearbyHospitals());
  }

  Future<void> refreshAmbulances() async {
    state = state.copyWith(ambulances: await _getNearbyAmbulances());
  }

  Future<void> refreshContacts() async {
    state = state.copyWith(contacts: await _getEmergencyContacts());
  }

  Future<void> refreshFirstAid() async {
    state = state.copyWith(firstAidGuides: await _getFirstAid());
  }

  Future<EmergencyEvent?> detectEmergency(String description) async {
    final trimmed = description.trim();
    if (trimmed.isEmpty || state.isBusy) return null;
    state = state.copyWith(status: EmergencyStatus.detecting, clearError: true);
    try {
      final event = await _repository.detectEmergency(trimmed);
      state = state.copyWith(status: EmergencyStatus.ready, activeEvent: event);
      return event;
    } catch (_) {
      state = state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: 'Could not detect the emergency type.',
      );
      return null;
    }
  }

  Future<void> triggerSos(EmergencyType type) async {
    if (state.isBusy) return;
    state = state.copyWith(
      status: EmergencyStatus.sendingSos,
      clearError: true,
    );
    try {
      final event = await _repository.triggerSos(type);
      final history = await _repository.getEmergencyHistory();
      state = state.copyWith(
        status: EmergencyStatus.ready,
        activeEvent: event,
        history: history,
      );
    } catch (_) {
      state = state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: 'Could not send SOS alert.',
      );
    }
  }

  Future<void> saveEvent(EmergencyEvent event, String actionTaken) async {
    await _saveEmergencyHistory(
      EmergencyHistory(
        id: 'manual-${DateTime.now().millisecondsSinceEpoch}',
        event: event,
        actionTaken: actionTaken,
        savedAt: DateTime.now(),
      ),
    );
    state = state.copyWith(history: await _repository.getEmergencyHistory());
  }
}
