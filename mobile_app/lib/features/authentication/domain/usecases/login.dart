import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class LoginUseCase {
  final AuthenticationRepository _repository;
  const LoginUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) =>
      _repository.login(email: email, password: password);
}
