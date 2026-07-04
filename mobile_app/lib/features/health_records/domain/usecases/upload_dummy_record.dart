import '../entities/medical_record.dart';
import '../entities/upload_record.dart';
import '../repositories/health_records_repository.dart';

class UploadDummyRecord {
  final HealthRecordsRepository repository;

  const UploadDummyRecord(this.repository);

  Future<MedicalRecord> call(UploadRecord record) {
    return repository.uploadDummyRecord(record);
  }
}
