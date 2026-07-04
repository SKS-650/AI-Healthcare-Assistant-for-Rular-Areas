import '../entities/user.dart';

abstract class AuthenticationRepository {
  /// Returns the currently cached user, or [UserEntity.empty] if none.
  Future<UserEntity> getCurrentUser();

  /// Sign in with email + password. Throws [AuthException] on failure.
  Future<UserEntity> login({required String email, required String password});

  /// Register a new account.
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  });

  /// Sign in as anonymous guest.
  Future<UserEntity> loginAsGuest();

  /// Send a forgot-password OTP to [email].
  /// Returns the OTP string in development mode (for testing without SMTP),
  /// null in production.
  Future<String?> forgotPassword({required String email});

  /// Verify the OTP for [email]. Returns a reset token on success.
  Future<String> verifyOtp({required String email, required String otp});

  /// Reset password using the [resetToken] returned by [verifyOtp].
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  /// Complete the user profile with additional data.
  Future<UserEntity> completeProfile({
    required String userId,
    required String name,
    String? phone,
    String? gender,
    int? age,
    String? language,
  });

  /// Sign out and clear local session.
  Future<void> logout();

  /// Whether onboarding has already been shown.
  Future<bool> hasSeenOnboarding();

  /// Mark onboarding as seen.
  Future<void> markOnboardingSeen();
}
