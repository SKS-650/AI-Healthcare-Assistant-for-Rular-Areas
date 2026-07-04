import '../entities/lab_report.dart';
import '../repositories/health_records_repository.dart';

class GetLabReports {
  final HealthRecordsRepository repository;

  const GetLabReports(this.repository);

  Future<List<LabReport>> call() {
    return repository.getLabReports();
  }
}
