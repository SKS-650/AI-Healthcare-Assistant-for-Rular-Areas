import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class CompleteProfileUseCase {
  final AuthenticationRepository _repository;
  const CompleteProfileUseCase(this._repository);

  Future<UserEntity> call({
    required String userId,
    required String name,
    String? phone,
    String? gender,
    int? age,
    String? language,
  }) =>
      _repository.completeProfile(
        userId: userId,
        name: name,
        phone: phone,
        gender: gender,
        age: age,
        language: language,
      );
}
