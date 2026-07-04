import 'doctor.dart';

class MedicalRecord {
  final String id;
  final String title;
  final String category;
  final String summary;
  final DateTime date;
  final Doctor doctor;
  final String status;
  final List<String> attachments;
  final List<String> tags;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.date,
    required this.doctor,
    required this.status,
    required this.attachments,
    required this.tags,
  });
}
