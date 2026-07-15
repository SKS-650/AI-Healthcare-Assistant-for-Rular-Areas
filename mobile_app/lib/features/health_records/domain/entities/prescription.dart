import 'doctor.dart';

class MedicineDosage {
  final String name;
  final String dose;
  final String frequency;
  final String duration;

  const MedicineDosage({
    required this.name,
    required this.dose,
    required this.frequency,
    required this.duration,
  });
}

class Prescription {
  final String id;
  final String diagnosis;
  final Doctor doctor;
  final DateTime prescribedAt;
  final DateTime? validUntil;
  final List<MedicineDosage> medicines;
  final String instructions;
  // File fields (null for locally-constructed dummy data)
  final String? fileUrl;
  final String? fileOriginalName;
  final String? notes;

  const Prescription({
    required this.id,
    required this.diagnosis,
    required this.doctor,
    required this.prescribedAt,
    this.validUntil,
    required this.medicines,
    required this.instructions,
    this.fileUrl,
    this.fileOriginalName,
    this.notes,
  });
}
