import '../entities/medical_record.dart';
import '../repositories/health_records_repository.dart';

class SearchRecords {
  final HealthRecordsRepository repository;

  const SearchRecords(this.repository);

  Future<List<MedicalRecord>> call(String query) {
    return repository.searchRecords(query);
  }
}
