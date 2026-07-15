import '../entities/emergency_assessment.dart';
import '../repositories/emergency_repository.dart';

class RunAssessment {
  final EmergencyRepository _repository;
  const RunAssessment(this._repository);

  Future<EmergencyAssessment> call(AssessmentInput input) =>
      _repository.runAssessment(input);
}
