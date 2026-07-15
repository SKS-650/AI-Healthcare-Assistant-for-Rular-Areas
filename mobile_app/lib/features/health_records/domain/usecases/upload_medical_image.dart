import '../entities/medical_image_record.dart';
import '../repositories/health_records_repository.dart';

class UploadMedicalImage {
  final HealthRecordsRepository repository;
  const UploadMedicalImage(this.repository);

  Future<MedicalImageRecord> call(MedicalImageRecord image) =>
      repository.uploadMedicalImage(image);
}
