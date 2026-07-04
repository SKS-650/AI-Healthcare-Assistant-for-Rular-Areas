/// Domain exception for all authentication-related errors.
///
/// Thrown by [AuthenticationRepository] implementations and caught by
/// [AuthenticationController] to display user-facing error messages.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
