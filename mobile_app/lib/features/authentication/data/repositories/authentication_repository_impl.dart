import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../datasources/auth_dummy_data.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  UserEntity? _cachedUser;
  bool _seenOnboarding = false;

  @override
  Future<UserEntity> getCurrentUser() async {
    return _cachedUser ?? UserEntity.empty;
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final user = await AuthDummyData.login(email, password);
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await AuthDummyData.register(name, email, password);
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserEntity> loginAsGuest() async {
    final user = await AuthDummyData.loginAsGuest();
    _cachedUser = user;
    return user;
  }

  @override
  Future<void> forgotPassword({required String email}) =>
      AuthDummyData.forgotPassword(email);

  @override
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) =>
      AuthDummyData.verifyOtp(email, otp);

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) =>
      AuthDummyData.resetPassword(resetToken, newPassword);

  @override
  Future<UserEntity> completeProfile({
    required String userId,
    required String name,
    String? phone,
    String? gender,
    int? age,
    String? language,
  }) async {
    final user = await AuthDummyData.completeProfile(
      userId,
      name,
      phone,
      gender,
      age,
      language,
    );
    _cachedUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _cachedUser = null;
  }

  @override
  Future<bool> hasSeenOnboarding() async => _seenOnboarding;

  @override
  Future<void> markOnboardingSeen() async {
    _seenOnboarding = true;
  }
}
