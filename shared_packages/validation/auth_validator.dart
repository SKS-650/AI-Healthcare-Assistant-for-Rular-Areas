class AuthValidator {
  const AuthValidator._();

  static bool isStrongPassword(String value) {
    return value.length >= 8;
  }
}
