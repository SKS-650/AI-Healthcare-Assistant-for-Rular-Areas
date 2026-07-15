import '../entities/medical_history_entry.dart';
import '../repositories/health_records_repository.dart';

class UpdateMedicalHistory {
  final HealthRecordsRepository repository;
  const UpdateMedicalHistory(this.repository);

  Future<MedicalHistoryEntry> call(MedicalHistoryEntry entry) =>
      repository.updateMedicalHistory(entry);
}
