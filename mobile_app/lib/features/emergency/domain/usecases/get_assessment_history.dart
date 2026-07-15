import '../entities/emergency_assessment.dart';
import '../repositories/emergency_repository.dart';

class GetAssessmentHistory {
  final EmergencyRepository _repository;
  const GetAssessmentHistory(this._repository);

  Future<List<EmergencyAssessment>> call({int limit = 20, int offset = 0}) =>
      _repository.getAssessmentHistory(limit: limit, offset: offset);
}
