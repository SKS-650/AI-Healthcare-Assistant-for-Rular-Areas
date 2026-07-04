class Validators {
  const Validators._();

  static bool isEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  static bool isRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
