import '../repositories/authentication_repository.dart';

class ForgotPasswordUseCase {
  final AuthenticationRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  Future<void> call({required String email}) =>
      _repository.forgotPassword(email: email);
}
