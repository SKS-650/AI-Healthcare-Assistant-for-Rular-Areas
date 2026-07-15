import '../entities/medical_history_entry.dart';
import '../repositories/health_records_repository.dart';

class GetMedicalHistory {
  final HealthRecordsRepository repository;
  const GetMedicalHistory(this.repository);

  Future<List<MedicalHistoryEntry>> call({String? category}) =>
      repository.getMedicalHistory(category: category);
}
