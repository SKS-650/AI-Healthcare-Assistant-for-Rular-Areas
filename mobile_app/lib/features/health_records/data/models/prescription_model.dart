import '../../domain/entities/prescription.dart';
import 'doctor_model.dart';

class MedicineDosageModel extends MedicineDosage {
  const MedicineDosageModel({
    required super.name,
    required super.dose,
    required super.frequency,
    required super.duration,
  });

  factory MedicineDosageModel.fromJson(Map<String, dynamic> json) =>
      MedicineDosageModel(
        name:      json['name'] as String? ?? '',
        dose:      json['dose'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        duration:  json['duration'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name':      name,
        'dose':      dose,
        'frequency': frequency,
        'duration':  duration,
      };
}

class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    required super.id,
    required super.diagnosis,
    required super.doctor,
    required super.prescribedAt,
    super.validUntil,
    required super.medicines,
    required super.instructions,
    super.fileUrl,
    super.fileOriginalName,
    super.notes,
  });

  /// Build from backend JSON response.
  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    final meds = (json['medicines'] as List<dynamic>? ?? [])
        .map((m) => MedicineDosageModel.fromJson(
            Map<String, dynamic>.from(m as Map)))
        .toList();

    // Backend stores doctor info flat — reconstruct a Doctor object
    final doctor = DoctorModel(
      id:            'remote',
      name:          json['doctor_name'] as String? ?? 'Unknown Doctor',
      specialty:     '',
      hospital:      json['hospital_name'] as String? ?? '',
      contactNumber: '',
    );

    return PrescriptionModel(
      id:               json['id'] as String,
      diagnosis:        json['diagnosis'] as String? ?? '',
      doctor:           doctor,
      prescribedAt:     json['prescription_date'] != null
          ? DateTime.parse(json['prescription_date'] as String)
          : DateTime.parse(json['created_at'] as String),
      validUntil:       json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      medicines:        meds,
      instructions:     json['instructions'] as String? ?? '',
      fileUrl:          json['file_url'] as String?,
      fileOriginalName: json['file_original_name'] as String?,
      notes:            json['notes'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'doctor_name':       doctor.name,
        'hospital_name':     doctor.hospital,
        'diagnosis':         diagnosis,
        if (validUntil != null)
          'valid_until':     validUntil!.toIso8601String(),
        'prescription_date': prescribedAt.toIso8601String(),
        'medicines':         medicines
            .map((m) => MedicineDosageModel(
                  name:      m.name,
                  dose:      m.dose,
                  frequency: m.frequency,
                  duration:  m.duration,
                ).toJson())
            .toList(),
        if (notes != null) 'notes': notes,
        'instructions': instructions,
      };
}
