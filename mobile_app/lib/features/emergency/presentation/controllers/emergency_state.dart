import '../../domain/entities/ambulance.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/entities/emergency_history.dart';
import '../../domain/entities/emergency_type.dart';
import '../../domain/entities/first_aid.dart';
import '../../domain/entities/hospital.dart';

enum EmergencyStatus { initial, loading, ready, sendingSos, detecting, error }

class EmergencyState {
  final EmergencyStatus status;
  final List<EmergencyType> types;
  final List<Hospital> hospitals;
  final List<Ambulance> ambulances;
  final List<EmergencyContact> contacts;
  final List<FirstAid> firstAidGuides;
  final List<EmergencyHistory> history;
  final EmergencyEvent? activeEvent;
  final String? errorMessage;

  const EmergencyState({
    this.status = EmergencyStatus.initial,
    this.types = const [],
    this.hospitals = const [],
    this.ambulances = const [],
    this.contacts = const [],
    this.firstAidGuides = const [],
    this.history = const [],
    this.activeEvent,
    this.errorMessage,
  });

  bool get isBusy {
    return status == EmergencyStatus.loading ||
        status == EmergencyStatus.sendingSos ||
        status == EmergencyStatus.detecting;
  }

  EmergencyState copyWith({
    EmergencyStatus? status,
    List<EmergencyType>? types,
    List<Hospital>? hospitals,
    List<Ambulance>? ambulances,
    List<EmergencyContact>? contacts,
    List<FirstAid>? firstAidGuides,
    List<EmergencyHistory>? history,
    EmergencyEvent? activeEvent,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmergencyState(
      status: status ?? this.status,
      types: types ?? this.types,
      hospitals: hospitals ?? this.hospitals,
      ambulances: ambulances ?? this.ambulances,
      contacts: contacts ?? this.contacts,
      firstAidGuides: firstAidGuides ?? this.firstAidGuides,
      history: history ?? this.history,
      activeEvent: activeEvent ?? this.activeEvent,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
