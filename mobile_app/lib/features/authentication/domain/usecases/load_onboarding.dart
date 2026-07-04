import '../repositories/authentication_repository.dart';

class LoadOnboardingUseCase {
  final AuthenticationRepository _repository;
  const LoadOnboardingUseCase(this._repository);

  Future<bool> hasSeenOnboarding() => _repository.hasSeenOnboarding();

  Future<void> markSeen() => _repository.markOnboardingSeen();
}
