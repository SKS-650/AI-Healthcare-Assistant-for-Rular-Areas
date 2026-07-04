import 'doctor.dart';

class Prescription {
  final String id;
  final String diagnosis;
  final Doctor doctor;
  final DateTime prescribedAt;
  final DateTime validUntil;
  final List<MedicineDosage> medicines;
  final String instructions;

  const Prescription({
    required this.id,
    required this.diagnosis,
    required this.doctor,
    required this.prescribedAt,
    required this.validUntil,
    required this.medicines,
    required this.instructions,
  });
}

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
