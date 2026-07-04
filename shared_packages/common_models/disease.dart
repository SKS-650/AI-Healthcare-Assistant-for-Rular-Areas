class Disease {
  const Disease({
    required this.id,
    required this.name,
    this.description,
    this.symptoms = const [],
  });

  final String id;
  final String name;
  final String? description;
  final List<String> symptoms;
}
