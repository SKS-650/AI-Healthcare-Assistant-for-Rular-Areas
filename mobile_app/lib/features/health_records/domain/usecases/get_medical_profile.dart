import '../entities/medical_profile.dart';
import '../repositories/health_records_repository.dart';

class GetMedicalProfile {
  final HealthRecordsRepository repository;
  const GetMedicalProfile(this.repository);

  Future<MedicalProfile> call() => repository.getMedicalProfile();
}
