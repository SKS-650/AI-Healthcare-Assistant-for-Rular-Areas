import 'package:flutter/foundation.dart';

import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../domain/entities/ambulance.dart';
import '../../domain/entities/emergency_assessment.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/entities/emergency_history.dart';
import '../../domain/entities/emergency_type.dart';
import '../../domain/entities/first_aid.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/risk_level.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_dummy_data.dart';
import '../datasources/emergency_remote_datasource.dart';
import '../models/emergency_contact_model.dart';
import '../models/emergency_event_model.dart';
import '../models/emergency_history_model.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final List<EmergencyHistory> _history = EmergencyDummyData.initialHistory();
  final EmergencyRemoteDatasource? _remote;

  EmergencyRepositoryImpl({EmergencyRemoteDatasource? remote})
      : _remote = remote;

  factory EmergencyRepositoryImpl.withAuth(
    AuthenticationRepositoryImpl authRepo,
  ) {
    return EmergencyRepositoryImpl(
      remote: EmergencyRemoteDatasource(authRepo),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Existing methods (unchanged behaviour)
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // New — AI Assessment
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<EmergencyAssessment> runAssessment(AssessmentInput input) async {
    if (_remote != null) {
      try {
        return await _remote.runAssessment(input);
      } catch (e) {
        debugPrint('[EmergencyRepo] runAssessment API error: $e — using fallback');
      }
    }
    return _localFallbackAssessment(input);
  }

  @override
  Future<List<EmergencyAssessment>> getAssessmentHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    if (_remote != null) {
      try {
        return await _remote.getAssessmentHistory(limit: limit, offset: offset);
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<EmergencyAssessment> getAssessmentById(String id) async {
    if (_remote != null) {
      return _remote.getAssessmentById(id);
    }
    throw Exception('Not available in offline mode');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // New — Contact CRUD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<EmergencyContact> createContact({
    required String name,
    required String phoneNumber,
    required String relation,
    bool isPrimary = false,
  }) async {
    if (_remote != null) {
      try {
        final data = await _remote.createContact(
          name: name,
          phoneNumber: phoneNumber,
          relation: relation,
          isPrimary: isPrimary,
        );
        return EmergencyContactModel(
          id: data['id'] as String,
          name: data['name'] as String,
          phoneNumber: data['phone_number'] as String,
          relation: data['relation'] as String? ?? relation,
          isPrimary: data['is_primary'] as bool? ?? isPrimary,
        );
      } catch (_) {}
    }
    return EmergencyContactModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phoneNumber: phoneNumber,
      relation: relation,
      isPrimary: isPrimary,
    );
  }

  @override
  Future<EmergencyContact> updateContact({
    required String contactId,
    String? name,
    String? phoneNumber,
    String? relation,
    bool? isPrimary,
  }) async {
    if (_remote != null) {
      final data = await _remote.updateContact(
        contactId: contactId,
        name: name,
        phoneNumber: phoneNumber,
        relation: relation,
        isPrimary: isPrimary,
      );
      return EmergencyContactModel(
        id: data['id'] as String,
        name: data['name'] as String,
        phoneNumber: data['phone_number'] as String,
        relation: data['relation'] as String? ?? '',
        isPrimary: data['is_primary'] as bool? ?? false,
      );
    }
    throw Exception('Update contact requires authentication');
  }

  @override
  Future<void> deleteContact(String contactId) async {
    if (_remote != null) {
      await _remote.deleteContact(contactId);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // New — SOS via API
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> triggerSosAlert({
    required String emergencyType,
    double? locationLat,
    double? locationLng,
    String? locationText,
    String? assessmentId,
  }) async {
    if (_remote != null) {
      try {
        await _remote.triggerSos(
          emergencyType: emergencyType,
          locationLat: locationLat,
          locationLng: locationLng,
          locationText: locationText,
          assessmentId: assessmentId,
        );
      } catch (e) {
        debugPrint('[EmergencyRepo] triggerSosAlert error: $e');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Local offline fallback assessment
  // ─────────────────────────────────────────────────────────────────────────

  EmergencyAssessment _localFallbackAssessment(AssessmentInput input) {
    final lower =
        '${input.description} ${input.symptoms.join(' ')}'.toLowerCase();

    String possibleEmergency = 'No immediate emergency detected';
    String dept = 'General Practitioner';
    String warning = '';
    bool isEmergency = false;
    int score = 10;
    RiskLevel riskLevel = RiskLevel.low;

    if (lower.contains('chest pain') ||
        lower.contains('heart') ||
        lower.contains('cardiac') ||
        lower.contains('heart attack')) {
      isEmergency = true;
      possibleEmergency = 'Cardiac Emergency';
      dept = 'Cardiology Emergency Unit';
      warning = '🚨 HEART EMERGENCY! Call 102 immediately.';
      score = 88;
      riskLevel = RiskLevel.critical;
    } else if (lower.contains('stroke') ||
        lower.contains('face drop') ||
        lower.contains('arm weak') ||
        lower.contains('speech')) {
      isEmergency = true;
      possibleEmergency = 'Stroke';
      dept = 'Neurology Emergency';
      warning = '🚨 POSSIBLE STROKE! Call 102 NOW.';
      score = 92;
      riskLevel = RiskLevel.critical;
    } else if (lower.contains('breath') ||
        lower.contains('chok') ||
        lower.contains('suffoc')) {
      isEmergency = true;
      possibleEmergency = 'Respiratory Emergency';
      dept = 'Emergency / Respiratory ICU';
      warning = '🚨 BREATHING EMERGENCY! Call 102 immediately.';
      score = 85;
      riskLevel = RiskLevel.critical;
    } else if (lower.contains('bleed') ||
        lower.contains('accident') ||
        lower.contains('snake') ||
        lower.contains('poison')) {
      isEmergency = true;
      possibleEmergency = 'Trauma / Emergency';
      dept = 'Trauma Emergency';
      warning = '🚨 EMERGENCY! Call 102 immediately.';
      score = 80;
      riskLevel = RiskLevel.high;
    } else if (lower.contains('fever') || input.symptoms.length >= 4) {
      isEmergency = true;
      possibleEmergency = 'High Fever / Possible Infection';
      dept = 'General Emergency';
      warning = '⚠️ HIGH FEVER — seek medical care urgently.';
      score = 60;
      riskLevel = RiskLevel.high;
    } else if (input.symptoms.isNotEmpty) {
      score = 35;
      riskLevel = RiskLevel.moderate;
      possibleEmergency = 'Possible illness — consult a doctor';
      dept = 'General Practitioner';
    }

    return EmergencyAssessment(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      isEmergency: isEmergency,
      riskScore: score,
      riskLevel: riskLevel,
      riskLevelColor: _riskColor(riskLevel),
      riskLevelEmoji: riskLevel.emoji,
      possibleEmergency: possibleEmergency,
      emergencyType: null,
      recommendedDept: dept,
      warningMessage: warning,
      sosRequired: riskLevel == RiskLevel.critical,
      firstAid: null,
      hospitalRecommendations: const [],
      matchedKeywords: const [],
      mlConfidence: 0.0,
      createdAt: DateTime.now(),
    );
  }

  static String _riskColor(RiskLevel level) => switch (level) {
    RiskLevel.low      => '#2ECC8B',
    RiskLevel.moderate => '#FFB829',
    RiskLevel.high     => '#FF7B3D',
    RiskLevel.critical => '#FF4757',
  };
}
