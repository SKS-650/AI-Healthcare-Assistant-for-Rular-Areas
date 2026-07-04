import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class GuestLoginUseCase {
  final AuthenticationRepository _repository;
  const GuestLoginUseCase(this._repository);

  Future<UserEntity> call() => _repository.loginAsGuest();
}
