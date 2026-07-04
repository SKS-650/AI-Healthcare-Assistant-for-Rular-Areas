import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

enum AuthFlow { idle, loading, success, error }

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
    String? pendingEmail,
    String? resetToken,
    String? devOtp,
  }) {
    return AuthenticationState(
      flow: flow ?? this.flow,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      resetToken: resetToken ?? this.resetToken,
      devOtp: devOtp ?? this.devOtp,
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
