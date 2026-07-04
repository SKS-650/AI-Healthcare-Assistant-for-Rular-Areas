import '../../domain/entities/prescription.dart';

class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    required super.id,
    required super.diagnosis,
    required super.doctor,
    required super.prescribedAt,
    required super.validUntil,
    required super.medicines,
    required super.instructions,
  });
}

class MedicineDosageModel extends MedicineDosage {
  const MedicineDosageModel({
    required super.name,
    required super.dose,
    required super.frequency,
    required super.duration,
  });
}
