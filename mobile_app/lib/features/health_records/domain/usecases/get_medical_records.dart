import '../entities/medical_record.dart';
import '../repositories/health_records_repository.dart';

class GetMedicalRecords {
  final HealthRecordsRepository repository;

  const GetMedicalRecords(this.repository);

  Future<List<MedicalRecord>> call() {
    return repository.getMedicalRecords();
  }
}
