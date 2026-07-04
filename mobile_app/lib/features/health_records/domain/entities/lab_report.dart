import 'doctor.dart';

class LabReport {
  final String id;
  final String testName;
  final String category;
  final DateTime testedAt;
  final Doctor doctor;
  final String labName;
  final String resultSummary;
  final String status;
  final Map<String, String> values;
  final List<String> attachments;

  const LabReport({
    required this.id,
    required this.testName,
    required this.category,
    required this.testedAt,
    required this.doctor,
    required this.labName,
    required this.resultSummary,
    required this.status,
    required this.values,
    required this.attachments,
  });
}
