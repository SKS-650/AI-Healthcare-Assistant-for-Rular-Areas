import '../../domain/entities/lab_report.dart';

class LabReportModel extends LabReport {
  const LabReportModel({
    required super.id,
    required super.testName,
    required super.category,
    required super.testedAt,
    required super.doctor,
    required super.labName,
    required super.resultSummary,
    required super.status,
    required super.values,
    required super.attachments,
  });
}
