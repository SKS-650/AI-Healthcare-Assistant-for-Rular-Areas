import '../entities/education_dashboard.dart';
import '../repositories/health_education_repository.dart';

class GetEducationDashboard {
  final HealthEducationRepository _repo;
  const GetEducationDashboard(this._repo);

  Future<EducationDashboard> call({String language = 'en'}) =>
      _repo.getDashboard(language: language);
}
