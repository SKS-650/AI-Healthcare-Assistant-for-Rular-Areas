String compactWhitespace(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
