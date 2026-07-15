class VaccinationRecord {
  final String name;
  final String? dateGiven;
  final String? dose;
  final String? nextDue;

  const VaccinationRecord({
    required this.name,
    this.dateGiven,
    this.dose,
    this.nextDue,
  });
}

class MedicalProfile {
  final String id;
  final String userId;
  final String? bloodGroup;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final String? smokingStatus;
  final String? alcoholStatus;
  final String? activityLevel;
  final List<String> allergies;
  final List<String> chronicDiseases;
  final List<String> currentMedications;
  final List<String> familyHistory;
  final List<VaccinationRecord> vaccinationHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicalProfile({
    required this.id,
    required this.userId,
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.smokingStatus,
    this.alcoholStatus,
    this.activityLevel,
    required this.allergies,
    required this.chronicDiseases,
    required this.currentMedications,
    required this.familyHistory,
    required this.vaccinationHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  String get bmiCategory {
    final b = bmi;
    if (b == null) return 'Unknown';
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  static MedicalProfile empty(String userId) => MedicalProfile(
        id: '',
        userId: userId,
        allergies: const [],
        chronicDiseases: const [],
        currentMedications: const [],
        familyHistory: const [],
        vaccinationHistory: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
