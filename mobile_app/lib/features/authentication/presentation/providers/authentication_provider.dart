import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/authentication_repository_impl.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/usecases/complete_profile.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/guest_login.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/verify_otp.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/authentication_state.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  return AuthenticationRepositoryImpl();
});

// ── Use-cases ─────────────────────────────────────────────────────────────────

final _loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);
final _registerUseCaseProvider = Provider(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);
final _logoutUseCaseProvider = Provider(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);
final _guestLoginUseCaseProvider = Provider(
  (ref) => GuestLoginUseCase(ref.watch(authRepositoryProvider)),
);
final _forgotPasswordUseCaseProvider = Provider(
  (ref) => ForgotPasswordUseCase(ref.watch(authRepositoryProvider)),
);
final _verifyOtpUseCaseProvider = Provider(
  (ref) => VerifyOtpUseCase(ref.watch(authRepositoryProvider)),
);
final _resetPasswordUseCaseProvider = Provider(
  (ref) => ResetPasswordUseCase(ref.watch(authRepositoryProvider)),
);
final _completeProfileUseCaseProvider = Provider(
  (ref) => CompleteProfileUseCase(ref.watch(authRepositoryProvider)),
);

// ── Controller ────────────────────────────────────────────────────────────────

final authControllerProvider =
    StateNotifierProvider<AuthenticationController, AuthenticationState>((ref) {
  return AuthenticationController(
    login: ref.watch(_loginUseCaseProvider),
    register: ref.watch(_registerUseCaseProvider),
    logout: ref.watch(_logoutUseCaseProvider),
    guestLogin: ref.watch(_guestLoginUseCaseProvider),
    forgotPassword: ref.watch(_forgotPasswordUseCaseProvider),
    verifyOtp: ref.watch(_verifyOtpUseCaseProvider),
    resetPassword: ref.watch(_resetPasswordUseCaseProvider),
    completeProfile: ref.watch(_completeProfileUseCaseProvider),
  );
});
