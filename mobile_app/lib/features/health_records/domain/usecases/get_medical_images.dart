import '../entities/medical_image_record.dart';
import '../repositories/health_records_repository.dart';

class GetMedicalImages {
  final HealthRecordsRepository repository;
  const GetMedicalImages(this.repository);

  Future<List<MedicalImageRecord>> call({String? imageType}) =>
      repository.getMedicalImages(imageType: imageType);
}
