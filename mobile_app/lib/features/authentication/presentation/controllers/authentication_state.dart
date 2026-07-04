import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

enum AuthFlow { idle, loading, success, error }

// Sentinel to distinguish "not passed" from explicit null in copyWith
class _Absent {
  const _Absent();
}

const _absent = _Absent();

class AuthenticationState extends Equatable {
  final AuthFlow flow;
  final UserEntity? user;
  final String? errorMessage;
  final String? successMessage;
  // For multi-step flows (forgot-password → OTP → reset)
  final String? pendingEmail;
  final String? resetToken;
  // Dev-mode only: OTP returned directly from backend when SMTP is not set up
  final String? devOtp;

  const AuthenticationState({
    this.flow = AuthFlow.idle,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.pendingEmail,
    this.resetToken,
    this.devOtp,
  });

  bool get isLoading => flow == AuthFlow.loading;
  bool get hasError => flow == AuthFlow.error;
  bool get isSuccess => flow == AuthFlow.success;

  AuthenticationState copyWith({
    AuthFlow? flow,
    UserEntity? user,
    String? errorMessage,
    String? successMessage,
    // Use Object? so callers can pass null explicitly to clear these fields
    Object? pendingEmail = _absent,
    Object? resetToken = _absent,
    Object? devOtp = _absent,
  }) {
    return AuthenticationState(
      flow: flow ?? this.flow,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      pendingEmail: pendingEmail is _Absent
          ? this.pendingEmail
          : pendingEmail as String?,
      resetToken: resetToken is _Absent
          ? this.resetToken
          : resetToken as String?,
      devOtp: devOtp is _Absent ? this.devOtp : devOtp as String?,
    );
  }

  @override
  List<Object?> get props => [
        flow,
        user,
        errorMessage,
        successMessage,
        pendingEmail,
        resetToken,
        devOtp,
      ];
}
