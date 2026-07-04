import '../repositories/authentication_repository.dart';

class ResetPasswordUseCase {
  final AuthenticationRepository _repository;
  const ResetPasswordUseCase(this._repository);

  Future<void> call({
    required String resetToken,
    required String newPassword,
  }) =>
      _repository.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
}
