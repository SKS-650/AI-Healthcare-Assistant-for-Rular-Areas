import '../entities/medical_history_entry.dart';
import '../repositories/health_records_repository.dart';

class CreateMedicalHistory {
  final HealthRecordsRepository repository;
  const CreateMedicalHistory(this.repository);

  Future<MedicalHistoryEntry> call(MedicalHistoryEntry entry) =>
      repository.createMedicalHistory(entry);
}
