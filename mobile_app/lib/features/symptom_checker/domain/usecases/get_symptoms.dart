import '../entities/symptom.dart';
import '../repositories/symptom_repository.dart';

class GetSymptoms {
  final SymptomRepository repository;

  const GetSymptoms(this.repository);

  Future<List<Symptom>> call() async {
    return await repository.getSymptoms();
  }
}