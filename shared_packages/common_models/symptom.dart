class Symptom {
  const Symptom({
    required this.id,
    required this.name,
    this.severity,
  });

  final String id;
  final String name;
  final int? severity;
}
