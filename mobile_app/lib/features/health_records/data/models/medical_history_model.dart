import '../../domain/entities/medical_history_entry.dart';

class MedicalHistoryModel extends MedicalHistoryEntry {
  const MedicalHistoryModel({
    required super.id,
    required super.userId,
    required super.diseaseName,
    required super.category,
    super.diagnosisDate,
    required super.status,
    super.doctorName,
    super.hospitalName,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MedicalHistoryModel.fromJson(Map<String, dynamic> json) =>
      MedicalHistoryModel(
        id:            json['id'] as String,
        userId:        json['user_id'] as String? ?? '',
        diseaseName:   json['disease_name'] as String,
        category:      json['category'] as String? ?? 'current',
        diagnosisDate: json['diagnosis_date'] != null
            ? DateTime.parse(json['diagnosis_date'] as String)
            : null,
        status:        json['status'] as String? ?? 'active',
        doctorName:    json['doctor_name'] as String?,
        hospitalName:  json['hospital_name'] as String?,
        notes:         json['notes'] as String?,
        createdAt:     DateTime.parse(json['created_at'] as String),
        updatedAt:     DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'disease_name':   diseaseName,
        'category':       category,
        'status':         status,
        if (diagnosisDate != null)
          'diagnosis_date': diagnosisDate!.toIso8601String(),
        if (doctorName != null)   'doctor_name':   doctorName,
        if (hospitalName != null) 'hospital_name': hospitalName,
        if (notes != null)        'notes':         notes,
      };

  /// Used for local offline cache keyed by id.
  Map<String, dynamic> toLocalJson() => {
        'id':            id,
        'user_id':       userId,
        'disease_name':  diseaseName,
        'category':      category,
        'diagnosis_date': diagnosisDate?.toIso8601String(),
        'status':        status,
        'doctor_name':   doctorName,
        'hospital_name': hospitalName,
        'notes':         notes,
        'created_at':    createdAt.toIso8601String(),
        'updated_at':    updatedAt.toIso8601String(),
      };
}
