class InputValidator {
  const InputValidator._();

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }
}
