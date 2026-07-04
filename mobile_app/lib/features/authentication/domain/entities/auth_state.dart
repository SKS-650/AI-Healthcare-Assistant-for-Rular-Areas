import 'package:equatable/equatable.dart';
import 'user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, guest }

class AuthStateEntity extends Equatable {
  final AuthStatus status;
  final UserEntity? user;

  const AuthStateEntity({required this.status, this.user});

  static const AuthStateEntity unknown =
      AuthStateEntity(status: AuthStatus.unknown);
  static const AuthStateEntity unauthenticated =
      AuthStateEntity(status: AuthStatus.unauthenticated);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;

  @override
  List<Object?> get props => [status, user];
}
