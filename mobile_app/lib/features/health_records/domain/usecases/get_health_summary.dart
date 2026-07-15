import '../entities/health_records_summary.dart';
import '../repositories/health_records_repository.dart';

class GetHealthSummary {
  final HealthRecordsRepository repository;
  const GetHealthSummary(this.repository);

  Future<HealthRecordsSummary> call() => repository.getSummary();
}
