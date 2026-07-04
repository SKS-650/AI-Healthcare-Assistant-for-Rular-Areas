import '../../domain/entities/lab_report.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/medical_timeline.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/entities/report_category.dart';

enum HealthRecordsStatus { initial, loading, loaded, uploading, failure }

class HealthRecordsState {
  final HealthRecordsStatus status;
  final List<MedicalRecord> records;
  final List<Prescription> prescriptions;
  final List<LabReport> labReports;
  final List<MedicalTimeline> timeline;
  final List<ReportCategory> categories;
  final List<MedicalRecord> searchResults;
  final String searchQuery;
  final String? errorMessage;

  const HealthRecordsState({
    this.status = HealthRecordsStatus.initial,
    this.records = const [],
    this.prescriptions = const [],
    this.labReports = const [],
    this.timeline = const [],
    this.categories = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  HealthRecordsState copyWith({
    HealthRecordsStatus? status,
    List<MedicalRecord>? records,
    List<Prescription>? prescriptions,
    List<LabReport>? labReports,
    List<MedicalTimeline>? timeline,
    List<ReportCategory>? categories,
    List<MedicalRecord>? searchResults,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HealthRecordsState(
      status: status ?? this.status,
      records: records ?? this.records,
      prescriptions: prescriptions ?? this.prescriptions,
      labReports: labReports ?? this.labReports,
      timeline: timeline ?? this.timeline,
      categories: categories ?? this.categories,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
