import '../repositories/health_records_repository.dart';

class DeleteMedicalHistory {
  final HealthRecordsRepository repository;
  const DeleteMedicalHistory(this.repository);

  Future<void> call(String id) => repository.deleteMedicalHistory(id);
}
