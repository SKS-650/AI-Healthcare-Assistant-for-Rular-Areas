import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/exceptions/auth_exception.dart';
import '../../domain/usecases/complete_profile.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/guest_login.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/verify_otp.dart';
import 'authentication_state.dart';

class AuthenticationController extends StateNotifier<AuthenticationState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GuestLoginUseCase _guestLogin;
  final ForgotPasswordUseCase _forgotPassword;
  final VerifyOtpUseCase _verifyOtp;
  final ResetPasswordUseCase _resetPassword;
  final CompleteProfileUseCase _completeProfile;

  AuthenticationController({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required GuestLoginUseCase guestLogin,
    required ForgotPasswordUseCase forgotPassword,
    required VerifyOtpUseCase verifyOtp,
    required ResetPasswordUseCase resetPassword,
    required CompleteProfileUseCase completeProfile,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _guestLogin = guestLogin,
        _forgotPassword = forgotPassword,
        _verifyOtp = verifyOtp,
        _resetPassword = resetPassword,
        _completeProfile = completeProfile,
        super(const AuthenticationState());

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(flow: AuthFlow.loading);
    try {
      final user = await _login(email: email, password: password);
      state = state.copyWith(flow: AuthFlow.success, user: user);
    } on AuthException catch (e) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(flow: AuthFlow.loading);
    try {
      final user = await _register(name: name, email: email, password: password);
      state = state.copyWith(flow: AuthFlow.success, user: user);
    } on AuthException catch (e) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: 'Registration failed. Please try again.',
      );
    }
  }

  // ── Guest Login ───────────────────────────────────────────────────────────

  Future<void> continueAsGuest() async {
    state = state.copyWith(flow: AuthFlow.loading);
    try {
      final user = await _guestLogin();
      state = state.copyWith(flow: AuthFlow.success, user: user);
    } catch (_) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: 'Unable to continue as guest.',
      );
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────

  Future<void> sendForgotPasswordOtp(String email) async {
    state = state.copyWith(flow: AuthFlow.loading);
    try {
      final devOtp = await _forgotPassword(email: email);
      state = state.copyWith(
        flow: AuthFlow.success,
        pendingEmail: email,
        devOtp: devOtp,
        successMessage: 'OTP sent to $email',
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: 'Failed to send OTP. Please try again.',
      );
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────

  Future<void> verifyOtp(String otp) async {
    final email = state.pendingEmail;
    if (email == null) return;

    state = state.copyWith(flow: AuthFlow.loading);
    try {
      final token = await _verifyOtp(email: email, otp: otp);
      state = state.copyWith(
        flow: AuthFlow.success,
        resetToken: token,
        successMessage: 'OTP verified!',
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: 'OTP verification failed.',
      );
    }
  }

  // ── Reset Password ────────────────────────────────────────────────────────

  Future<void> resetPassword(String newPassword) async {
    final token = state.resetToken;
    if (token == null) return;

    state = state.copyWith(flow: AuthFlow.loading);
    try {
      await _resetPassword(resetToken: token, newPassword: newPassword);
      state = state.copyWith(
        flow: AuthFlow.success,
        resetToken: null,
        pendingEmail: null,
        successMessage: 'Password reset successfully!',
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: 'Password reset failed.',
      );
    }
  }

  // ── Complete Profile ──────────────────────────────────────────────────────

  Future<void> completeProfile({
    required String userId,
    required String name,
    String? phone,
    String? gender,
    int? age,
    String? language,
  }) async {
    state = state.copyWith(flow: AuthFlow.loading);
    try {
      final user = await _completeProfile(
        userId: userId,
        name: name,
        phone: phone,
        gender: gender,
        age: age,
        language: language,
      );
      state = state.copyWith(flow: AuthFlow.success, user: user);
    } on AuthException catch (e) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        flow: AuthFlow.error,
        errorMessage: 'Profile update failed.',
      );
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _logout();
    state = const AuthenticationState();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void clearError() {
    if (state.hasError) {
      state = state.copyWith(flow: AuthFlow.idle);
    }
  }

  void reset() {
    state = const AuthenticationState();
  }
}
