import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/medical_history_entry.dart';
import '../../domain/entities/medical_image_record.dart';
import '../../domain/entities/medical_profile.dart';
import '../../domain/entities/upload_record.dart';
import '../../domain/repositories/health_records_repository.dart';
import '../../domain/usecases/create_medical_history.dart';
import '../../domain/usecases/delete_medical_history.dart';
import '../../domain/usecases/get_health_summary.dart';
import '../../domain/usecases/get_lab_reports.dart';
import '../../domain/usecases/get_medical_history.dart';
import '../../domain/usecases/get_medical_images.dart';
import '../../domain/usecases/get_medical_profile.dart';
import '../../domain/usecases/get_medical_records.dart';
import '../../domain/usecases/get_medical_timeline.dart';
import '../../domain/usecases/get_prescriptions.dart';
import '../../domain/usecases/get_timeline_events.dart';
import '../../domain/usecases/search_records.dart';
import '../../domain/usecases/update_medical_history.dart';
import '../../domain/usecases/upload_dummy_record.dart';
import '../../domain/usecases/upload_medical_image.dart';
import '../../domain/usecases/upsert_medical_profile.dart';
import 'health_records_state.dart';

class HealthRecordsController extends StateNotifier<HealthRecordsState> {
  // ── Use cases ─────────────────────────────────────────────────────────────
  final GetMedicalRecords getMedicalRecords;
  final GetPrescriptions getPrescriptions;
  final GetLabReports getLabReports;
  final GetMedicalTimeline getMedicalTimeline;
  final UploadDummyRecord uploadDummyRecord;
  final SearchRecords searchRecords;
  final GetMedicalProfile getMedicalProfile;
  final UpsertMedicalProfile upsertMedicalProfile;
  final GetMedicalHistory getMedicalHistory;
  final CreateMedicalHistory createMedicalHistory;
  final UpdateMedicalHistory updateMedicalHistory;
  final DeleteMedicalHistory deleteMedicalHistory;
  final GetMedicalImages getMedicalImages;
  final UploadMedicalImage uploadMedicalImage;
  final GetTimelineEvents getTimelineEvents;
  final GetHealthSummary getHealthSummary;
  final HealthRecordsRepository repository;

  HealthRecordsController({
    required this.getMedicalRecords,
    required this.getPrescriptions,
    required this.getLabReports,
    required this.getMedicalTimeline,
    required this.uploadDummyRecord,
    required this.searchRecords,
    required this.getMedicalProfile,
    required this.upsertMedicalProfile,
    required this.getMedicalHistory,
    required this.createMedicalHistory,
    required this.updateMedicalHistory,
    required this.deleteMedicalHistory,
    required this.getMedicalImages,
    required this.uploadMedicalImage,
    required this.getTimelineEvents,
    required this.getHealthSummary,
    required this.repository,
  }) : super(const HealthRecordsState()) {
    loadAll();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Initial / refresh load
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    state = state.copyWith(status: HealthRecordsStatus.loading, clearError: true);
    try {
      // Fire all fetches in parallel for speed.
      final results = await Future.wait([
        getMedicalRecords(),           // 0
        getPrescriptions(),            // 1
        getLabReports(),               // 2
        getMedicalTimeline(),          // 3
        repository.getCategories(),    // 4
        getMedicalProfile(),           // 5
        getMedicalHistory(),           // 6
        getMedicalImages(),            // 7
        getTimelineEvents(),           // 8
        getHealthSummary(),            // 9
      ]);

      state = state.copyWith(
        status:         HealthRecordsStatus.loaded,
        records:        results[0] as dynamic,
        prescriptions:  results[1] as dynamic,
        labReports:     results[2] as dynamic,
        timeline:       results[3] as dynamic,
        categories:     results[4] as dynamic,
        medicalProfile: results[5] as dynamic,
        medicalHistory: results[6] as dynamic,
        medicalImages:  results[7] as dynamic,
        timelineEvents: results[8] as dynamic,
        summary:        results[9] as dynamic,
        searchResults:  results[0] as dynamic,
      );
    } catch (e) {
      state = state.copyWith(
        status: HealthRecordsStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  // Alias kept so existing widgets that call loadRecords() still compile.
  Future<void> loadRecords() => loadAll();

  // ─────────────────────────────────────────────────────────────────────────
  // Search
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> search(String query) async {
    try {
      final results = await searchRecords(query);
      state = state.copyWith(searchQuery: query, searchResults: results);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Legacy upload
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> upload(UploadRecord record) async {
    state = state.copyWith(status: HealthRecordsStatus.uploading, clearError: true);
    try {
      await uploadDummyRecord(record);
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.failure, errorMessage: e.toString());
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical Profile
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> saveProfile(MedicalProfile profile) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      final updated = await upsertMedicalProfile(profile);
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, medicalProfile: updated);
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.failure, errorMessage: e.toString());
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical History
  // ─────────────────────────────────────────────────────────────────────────

  void setHistoryFilter(String? category) {
    state = state.copyWith(
      activeHistoryCategory: category,
      clearHistoryCategory: category == null,
    );
  }

  Future<bool> addHistoryEntry(MedicalHistoryEntry entry) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      final created = await createMedicalHistory(entry);
      state = state.copyWith(
        status: HealthRecordsStatus.loaded,
        medicalHistory: [created, ...state.medicalHistory],
      );
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.failure, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> editHistoryEntry(MedicalHistoryEntry entry) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      final updated = await updateMedicalHistory(entry);
      final newList = state.medicalHistory
          .map((e) => e.id == updated.id ? updated : e)
          .toList();
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, medicalHistory: newList);
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.failure, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removeHistoryEntry(String id) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      await deleteMedicalHistory(id);
      final newList = state.medicalHistory.where((e) => e.id != id).toList();
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, medicalHistory: newList);
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.failure, errorMessage: e.toString());
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical Images
  // ─────────────────────────────────────────────────────────────────────────

  void setImageTypeFilter(String? type) {
    state = state.copyWith(
      activeImageType: type,
      clearImageType: type == null,
    );
  }

  Future<bool> addMedicalImage(MedicalImageRecord image) async {
    state = state.copyWith(status: HealthRecordsStatus.uploading, clearError: true);
    try {
      final uploaded = await uploadMedicalImage(image);
      state = state.copyWith(
        status: HealthRecordsStatus.loaded,
        medicalImages: [uploaded, ...state.medicalImages],
      );
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.failure, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removeMedicalImage(String id) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      await repository.deleteMedicalImage(id);
      final newList = state.medicalImages.where((i) => i.id != id).toList();
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, medicalImages: newList);
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.failure, errorMessage: e.toString());
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timeline filter
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadTimelineFiltered(String? eventType) async {
    try {
      final events = await getTimelineEvents(eventType: eventType);
      state = state.copyWith(timelineEvents: events);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _refreshSummary() async {
    try {
      final s = await getHealthSummary();
      state = state.copyWith(summary: s);
    } catch (_) {}
  }
}
