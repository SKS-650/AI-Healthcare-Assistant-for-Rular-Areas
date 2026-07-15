import '../../domain/entities/health_records_summary.dart';
import '../../domain/entities/lab_report.dart';
import '../../domain/entities/medical_history_entry.dart';
import '../../domain/entities/medical_image_record.dart';
import '../../domain/entities/medical_profile.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/medical_timeline.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/entities/report_category.dart';
import '../../domain/entities/timeline_event.dart';

enum HealthRecordsStatus { initial, loading, loaded, uploading, saving, failure }

class HealthRecordsState {
  // ── Status ────────────────────────────────────────────────────────────────
  final HealthRecordsStatus status;
  final String? errorMessage;

  // ── Legacy records ────────────────────────────────────────────────────────
  final List<MedicalRecord> records;
  final List<Prescription> prescriptions;
  final List<LabReport> labReports;
  final List<MedicalTimeline> timeline;
  final List<ReportCategory> categories;
  final List<MedicalRecord> searchResults;
  final String searchQuery;

  // ── New PHR entities ──────────────────────────────────────────────────────
  final MedicalProfile? medicalProfile;
  final List<MedicalHistoryEntry> medicalHistory;
  final List<MedicalImageRecord> medicalImages;
  final List<TimelineEvent> timelineEvents;
  final HealthRecordsSummary? summary;

  // ── Active filters ────────────────────────────────────────────────────────
  final String? activeHistoryCategory;  // null = all
  final String? activeImageType;        // null = all

  const HealthRecordsState({
    this.status = HealthRecordsStatus.initial,
    this.errorMessage,
    this.records = const [],
    this.prescriptions = const [],
    this.labReports = const [],
    this.timeline = const [],
    this.categories = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.medicalProfile,
    this.medicalHistory = const [],
    this.medicalImages = const [],
    this.timelineEvents = const [],
    this.summary,
    this.activeHistoryCategory,
    this.activeImageType,
  });

  HealthRecordsState copyWith({
    HealthRecordsStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<MedicalRecord>? records,
    List<Prescription>? prescriptions,
    List<LabReport>? labReports,
    List<MedicalTimeline>? timeline,
    List<ReportCategory>? categories,
    List<MedicalRecord>? searchResults,
    String? searchQuery,
    MedicalProfile? medicalProfile,
    List<MedicalHistoryEntry>? medicalHistory,
    List<MedicalImageRecord>? medicalImages,
    List<TimelineEvent>? timelineEvents,
    HealthRecordsSummary? summary,
    String? activeHistoryCategory,
    bool clearHistoryCategory = false,
    String? activeImageType,
    bool clearImageType = false,
  }) {
    return HealthRecordsState(
      status:                 status ?? this.status,
      errorMessage:           clearError ? null : errorMessage ?? this.errorMessage,
      records:                records ?? this.records,
      prescriptions:          prescriptions ?? this.prescriptions,
      labReports:             labReports ?? this.labReports,
      timeline:               timeline ?? this.timeline,
      categories:             categories ?? this.categories,
      searchResults:          searchResults ?? this.searchResults,
      searchQuery:            searchQuery ?? this.searchQuery,
      medicalProfile:         medicalProfile ?? this.medicalProfile,
      medicalHistory:         medicalHistory ?? this.medicalHistory,
      medicalImages:          medicalImages ?? this.medicalImages,
      timelineEvents:         timelineEvents ?? this.timelineEvents,
      summary:                summary ?? this.summary,
      activeHistoryCategory:  clearHistoryCategory ? null
          : activeHistoryCategory ?? this.activeHistoryCategory,
      activeImageType:        clearImageType ? null
          : activeImageType ?? this.activeImageType,
    );
  }

  // ── Convenience getters ───────────────────────────────────────────────────

  bool get isLoading  => status == HealthRecordsStatus.loading;
  bool get isUploading => status == HealthRecordsStatus.uploading
      || status == HealthRecordsStatus.saving;
  bool get hasError   => errorMessage != null;

  /// Filtered history based on active category selector.
  List<MedicalHistoryEntry> get filteredHistory {
    if (activeHistoryCategory == null) return medicalHistory;
    return medicalHistory
        .where((e) => e.category == activeHistoryCategory)
        .toList();
  }

  /// Filtered images based on active type selector.
  List<MedicalImageRecord> get filteredImages {
    if (activeImageType == null) return medicalImages;
    return medicalImages
        .where((i) => i.imageType == activeImageType)
        .toList();
  }

  int get totalRecordCount =>
      records.length + prescriptions.length + labReports.length +
      medicalHistory.length + medicalImages.length;
}
