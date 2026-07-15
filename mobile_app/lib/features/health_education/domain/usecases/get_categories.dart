import '../entities/health_category.dart';
import '../repositories/health_education_repository.dart';

class GetEducationCategories {
  final HealthEducationRepository _repo;
  const GetEducationCategories(this._repo);

  Future<List<HealthCategory>> call() => _repo.getCategories();
}
