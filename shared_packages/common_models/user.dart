class User {
  const User({
    required this.id,
    this.email,
    this.name,
    this.roles = const [],
  });

  final String id;
  final String? email;
  final String? name;
  final List<String> roles;
}
