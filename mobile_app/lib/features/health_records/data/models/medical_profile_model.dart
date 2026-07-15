import '../../domain/entities/medical_profile.dart';

class VaccinationRecordModel extends VaccinationRecord {
  const VaccinationRecordModel({
    required super.name,
    super.dateGiven,
    super.dose,
    super.nextDue,
  });

  factory VaccinationRecordModel.fromJson(Map<String, dynamic> json) =>
      VaccinationRecordModel(
        name:      json['name'] as String? ?? '',
        dateGiven: json['date_given'] as String?,
        dose:      json['dose'] as String?,
        nextDue:   json['next_due'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name':       name,
        if (dateGiven != null) 'date_given': dateGiven,
        if (dose != null) 'dose': dose,
        if (nextDue != null) 'next_due': nextDue,
      };
}

class MedicalProfileModel extends MedicalProfile {
  const MedicalProfileModel({
    required super.id,
    required super.userId,
    super.bloodGroup,
    super.heightCm,
    super.weightKg,
    super.bmi,
    super.smokingStatus,
    super.alcoholStatus,
    super.activityLevel,
    required super.allergies,
    required super.chronicDiseases,
    required super.currentMedications,
    required super.familyHistory,
    required super.vaccinationHistory,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MedicalProfileModel.fromJson(Map<String, dynamic> json) {
    List<String> strings(dynamic v) =>
        (v as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    List<VaccinationRecord> vaccinations(dynamic v) =>
        (v as List<dynamic>? ?? [])
            .map((e) => VaccinationRecordModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();

    return MedicalProfileModel(
      id:                   json['id'] as String? ?? '',
      userId:               json['user_id'] as String? ?? '',
      bloodGroup:           json['blood_group'] as String?,
      heightCm:             (json['height_cm'] as num?)?.toDouble(),
      weightKg:             (json['weight_kg'] as num?)?.toDouble(),
      bmi:                  (json['bmi'] as num?)?.toDouble(),
      smokingStatus:        json['smoking_status'] as String?,
      alcoholStatus:        json['alcohol_status'] as String?,
      activityLevel:        json['activity_level'] as String?,
      allergies:            strings(json['allergies']),
      chronicDiseases:      strings(json['chronic_diseases']),
      currentMedications:   strings(json['current_medications']),
      familyHistory:        strings(json['family_history']),
      vaccinationHistory:   vaccinations(json['vaccination_history']),
      createdAt:            DateTime.parse(json['created_at'] as String),
      updatedAt:            DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'blood_group':         bloodGroup,
        'height_cm':           heightCm,
        'weight_kg':           weightKg,
        'smoking_status':      smokingStatus,
        'alcohol_status':      alcoholStatus,
        'activity_level':      activityLevel,
        'allergies':           allergies,
        'chronic_diseases':    chronicDiseases,
        'current_medications': currentMedications,
        'family_history':      familyHistory,
        'vaccination_history': vaccinationHistory
            .map((v) => VaccinationRecordModel(
                  name:      v.name,
                  dateGiven: v.dateGiven,
                  dose:      v.dose,
                  nextDue:   v.nextDue,
                ).toJson())
            .toList(),
      };
}
