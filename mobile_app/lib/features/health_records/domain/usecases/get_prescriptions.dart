import '../entities/prescription.dart';
import '../repositories/health_records_repository.dart';

class GetPrescriptions {
  final HealthRecordsRepository repository;

  const GetPrescriptions(this.repository);

  Future<List<Prescription>> call() {
    return repository.getPrescriptions();
  }
}
