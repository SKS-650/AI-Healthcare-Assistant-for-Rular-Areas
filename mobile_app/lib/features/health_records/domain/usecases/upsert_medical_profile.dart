import '../entities/medical_profile.dart';
import '../repositories/health_records_repository.dart';

class UpsertMedicalProfile {
  final HealthRecordsRepository repository;
  const UpsertMedicalProfile(this.repository);

  Future<MedicalProfile> call(MedicalProfile profile) =>
      repository.upsertMedicalProfile(profile);
}
