class MedicalTimeline {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime occurredAt;
  final String doctorName;

  const MedicalTimeline({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.occurredAt,
    required this.doctorName,
  });
}
