import '../repositories/authentication_repository.dart';

class VerifyOtpUseCase {
  final AuthenticationRepository _repository;
  const VerifyOtpUseCase(this._repository);

  /// Returns reset token on success.
  Future<String> call({required String email, required String otp}) =>
      _repository.verifyOtp(email: email, otp: otp);
}
