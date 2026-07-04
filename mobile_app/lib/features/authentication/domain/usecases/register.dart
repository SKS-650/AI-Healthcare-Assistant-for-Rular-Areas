import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class RegisterUseCase {
  final AuthenticationRepository _repository;
  const RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
  }) =>
      _repository.register(name: name, email: email, password: password);
}
