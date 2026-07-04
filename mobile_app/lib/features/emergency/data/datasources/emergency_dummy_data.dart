import '../models/ambulance_model.dart';
import '../models/emergency_contact_model.dart';
import '../models/emergency_event_model.dart';
import '../models/emergency_history_model.dart';
import '../models/emergency_type_model.dart';
import '../models/first_aid_model.dart';
import '../models/hospital_model.dart';

class EmergencyDummyData {
  static const emergencyTypes = [
    EmergencyTypeModel(
      id: 'cardiac',
      title: 'Chest Pain',
      description: 'Possible heart or breathing emergency.',
      severity: 'Critical',
    ),
    EmergencyTypeModel(
      id: 'injury',
      title: 'Severe Injury',
      description: 'Bleeding, fracture, fall, or accident support.',
      severity: 'High',
    ),
    EmergencyTypeModel(
      id: 'breathing',
      title: 'Breathing Trouble',
      description: 'Shortness of breath, choking, or asthma attack.',
      severity: 'Critical',
    ),
    EmergencyTypeModel(
      id: 'allergy',
      title: 'Allergic Reaction',
      description: 'Swelling, rash, wheezing, or anaphylaxis signs.',
      severity: 'High',
    ),
  ];

  static const hospitals = [
    HospitalModel(
      id: 'h1',
      name: 'City General Emergency Center',
      address: 'Health Avenue, Downtown',
      distanceKm: 1.2,
      phoneNumber: '102',
    ),
    HospitalModel(
      id: 'h2',
      name: 'Metro Trauma Hospital',
      address: 'Care Road, North District',
      distanceKm: 2.8,
      phoneNumber: '+977-01-4455667',
    ),
    HospitalModel(
      id: 'h3',
      name: 'Community Medical Clinic',
      address: 'Main Street, Ward 7',
      distanceKm: 4.1,
      phoneNumber: '+977-01-4411223',
      emergencyAvailable: false,
    ),
  ];

  static const ambulances = [
    AmbulanceModel(
      id: 'a1',
      providerName: 'Rapid Response Ambulance',
      driverName: 'Ramesh Thapa',
      phoneNumber: '102',
      distanceKm: 0.9,
      etaMinutes: 5,
    ),
    AmbulanceModel(
      id: 'a2',
      providerName: 'City Care Ambulance',
      driverName: 'Sita Karki',
      phoneNumber: '+977-9841000000',
      distanceKm: 1.7,
      etaMinutes: 9,
    ),
    AmbulanceModel(
      id: 'a3',
      providerName: 'Valley Emergency Service',
      driverName: 'Arjun Lama',
      phoneNumber: '+977-9800000000',
      distanceKm: 3.3,
      etaMinutes: 14,
      available: false,
    ),
  ];

  static const contacts = [
    EmergencyContactModel(
      id: 'c1',
      name: 'Family Doctor',
      phoneNumber: '+977-01-4444444',
      relation: 'Doctor',
      isPrimary: true,
    ),
    EmergencyContactModel(
      id: 'c2',
      name: 'Asha Sharma',
      phoneNumber: '+977-9841234567',
      relation: 'Family',
    ),
    EmergencyContactModel(
      id: 'c3',
      name: 'Local Police',
      phoneNumber: '100',
      relation: 'Public service',
    ),
  ];

  static const firstAidGuides = [
    FirstAidModel(
      id: 'f1',
      title: 'Chest Pain',
      category: 'Critical',
      summary:
          'Act fast if chest pain is severe, spreading, or paired with sweating or breathlessness.',
      steps: [
        'Call emergency services immediately.',
        'Keep the person seated and calm.',
        'Loosen tight clothing and monitor breathing.',
        'Do not give food or drink.',
      ],
    ),
    FirstAidModel(
      id: 'f2',
      title: 'Heavy Bleeding',
      category: 'Injury',
      summary: 'Apply pressure and seek urgent care.',
      steps: [
        'Press firmly on the wound with clean cloth.',
        'Raise the injured area if possible.',
        'Do not remove embedded objects.',
        'Call an ambulance if bleeding does not slow.',
      ],
    ),
    FirstAidModel(
      id: 'f3',
      title: 'Choking',
      category: 'Breathing',
      summary:
          'Use back blows and abdominal thrusts for a conscious choking adult.',
      steps: [
        'Ask if the person can cough or speak.',
        'Give 5 firm back blows.',
        'Give 5 abdominal thrusts if needed.',
        'Call emergency services if the blockage remains.',
      ],
    ),
  ];

  static EmergencyEventModel defaultEvent() {
    return EmergencyEventModel(
      id: 'event-${DateTime.now().millisecondsSinceEpoch}',
      type: emergencyTypes.first,
      status: 'Monitoring',
      createdAt: DateTime.now(),
      location: 'Current location',
    );
  }

  static List<EmergencyHistoryModel> initialHistory() {
    final event = EmergencyEventModel(
      id: 'history-event-1',
      type: emergencyTypes[1],
      status: 'Resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      location: 'Home',
      sosSent: true,
    );
    return [
      EmergencyHistoryModel(
        id: 'history-1',
        event: event,
        actionTaken: 'Contacted family doctor and nearby ambulance.',
        savedAt: event.createdAt,
      ),
    ];
  }
}
