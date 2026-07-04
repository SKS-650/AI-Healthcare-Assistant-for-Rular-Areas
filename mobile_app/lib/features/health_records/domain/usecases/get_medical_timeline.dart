import '../entities/medical_timeline.dart';
import '../repositories/health_records_repository.dart';

class GetMedicalTimeline {
  final HealthRecordsRepository repository;

  const GetMedicalTimeline(this.repository);

  Future<List<MedicalTimeline>> call() {
    return repository.getMedicalTimeline();
  }
}
