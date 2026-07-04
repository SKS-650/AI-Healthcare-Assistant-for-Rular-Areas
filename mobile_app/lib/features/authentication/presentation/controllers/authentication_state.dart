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

  const AuthenticationState({
    this.flow = AuthFlow.idle,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.pendingEmail,
    this.resetToken,
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
  }) {
    return AuthenticationState(
      flow: flow ?? this.flow,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      resetToken: resetToken ?? this.resetToken,
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
      ];
}
