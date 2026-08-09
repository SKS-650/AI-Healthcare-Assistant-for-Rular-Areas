import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/health_records_summary.dart';
import '../../domain/entities/medical_history_entry.dart';
import '../../domain/entities/medical_image_record.dart';
import '../../domain/entities/medical_profile.dart';
import '../../domain/entities/prescription.dart';
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
  //
  // Each fetch runs independently with its own try/catch so a failure in one
  // (e.g. network timeout on summary) never prevents other data from loading.
  // The error banner only appears when the backend is truly unreachable.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    state = state.copyWith(status: HealthRecordsStatus.loading, clearError: true);

    // Results holders — start with whatever is already in state.
    var records        = state.records;
    var prescriptions  = state.prescriptions;
    var labReports     = state.labReports;
    var timeline       = state.timeline;
    var categories     = state.categories;
    MedicalProfile? medicalProfile = state.medicalProfile;
    var medicalHistory = state.medicalHistory;
    var medicalImages  = state.medicalImages;
    var timelineEvents = state.timelineEvents;
    HealthRecordsSummary? summary = state.summary;

    // Count how many network calls actually failed (not just "empty list").
    int networkFailures = 0;
    String? lastNetworkError;

    // Helper: run a typed fetch, keep the current value on error.
    Future<T> fetch<T>(Future<T> call, T current) async {
      try {
        return await call;
      } catch (e) {
        // Only flag TRUE connectivity / auth failures that prevent the user
        // from seeing their data.  404 / "not found" is NOT an error here —
        // it just means the user has no records yet (empty state).
        final msg = e.toString().toLowerCase();
        final isNetworkError = msg.contains('cannot connect') ||
            msg.contains('socketexception') ||
            msg.contains('networkexception') ||
            msg.contains('serveroffline') ||
            msg.contains('handshakeexception') ||
            msg.contains('clientexception') ||
            msg.contains('timeout') ||
            msg.contains('connection refused') ||
            msg.contains('connection timed out') ||
            msg.contains('failed host lookup') ||
            msg.contains('401') ||
            msg.contains('403') ||
            msg.contains('500') ||
            msg.contains('502') ||
            msg.contains('503');
        // 404 / "not found" means the user has no records — silent empty state.
        if (isNetworkError) {
          networkFailures++;
          lastNetworkError = e.toString();
        }
        return current;
      }
    }

    // Run all fetches concurrently but each has its own error boundary.
    await Future.wait([
      fetch(getMedicalRecords(),        records       ).then((v) => records        = v),
      fetch(getPrescriptions(),         prescriptions ).then((v) => prescriptions  = v),
      fetch(getLabReports(),            labReports    ).then((v) => labReports     = v),
      fetch(getMedicalTimeline(),       timeline      ).then((v) => timeline       = v),
      fetch(repository.getCategories(), categories    ).then((v) => categories     = v),
      fetch(getMedicalProfile(),        medicalProfile).then((v) => medicalProfile = v),
      fetch(getMedicalHistory(),        medicalHistory).then((v) => medicalHistory = v),
      fetch(getMedicalImages(),         medicalImages ).then((v) => medicalImages  = v),
      fetch(getTimelineEvents(),        timelineEvents).then((v) => timelineEvents = v),
      fetch(getHealthSummary(),         summary       ).then((v) => summary        = v),
    ]);

    state = state.copyWith(
      status:         HealthRecordsStatus.loaded,
      records:        records,
      prescriptions:  prescriptions,
      labReports:     labReports,
      timeline:       timeline,
      categories:     categories,
      medicalProfile: medicalProfile,
      medicalHistory: medicalHistory,
      medicalImages:  medicalImages,
      timelineEvents: timelineEvents,
      summary:        summary,
      searchResults:  records,
      // Only show error banner when backend is unreachable — not for empty lists.
      errorMessage:   networkFailures > 0 ? _friendlyError(lastNetworkError) : null,
      clearError:     networkFailures == 0,
    );
  }

  String _friendlyError(String? raw) {
    if (raw == null) return 'Could not connect to server.';
    final msg = raw.toLowerCase();
    if (msg.contains('cannot connect') ||
        msg.contains('socketexception') ||
        msg.contains('serveroffline') ||
        msg.contains('clientexception') ||
        msg.contains('handshakeexception') ||
        msg.contains('connection refused')) {
      return 'Cannot reach server. Make sure the backend is running and your device is on the same Wi-Fi.';
    }
    if (msg.contains('timeout')) return 'Connection timed out. Check your Wi-Fi.';
    if (msg.contains('401') || msg.contains('403')) {
      return 'Session expired. Please log out and log back in.';
    }
    if (msg.contains('500') || msg.contains('502') || msg.contains('503')) {
      return 'Server error. Please try again in a moment.';
    }
    return 'Some records could not be loaded. Cached data shown.';
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
    } catch (_) {}
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
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
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
          status: HealthRecordsStatus.loaded, medicalProfile: updated, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
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
        clearError: true,
      );
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
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
          status: HealthRecordsStatus.loaded, medicalHistory: newList, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removeHistoryEntry(String id) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      await deleteMedicalHistory(id);
      final newList = state.medicalHistory.where((e) => e.id != id).toList();
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, medicalHistory: newList, clearError: true);
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
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
        clearError: true,
      );
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removeMedicalImage(String id) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      await repository.deleteMedicalImage(id);
      final newList = state.medicalImages.where((i) => i.id != id).toList();
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, medicalImages: newList, clearError: true);
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Prescriptions
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> createPrescription(Prescription prescription) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      final created = await repository.createPrescription(prescription);
      state = state.copyWith(
        status: HealthRecordsStatus.loaded,
        prescriptions: [created, ...state.prescriptions],
        clearError: true,
      );
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removePrescription(String id) async {
    state = state.copyWith(status: HealthRecordsStatus.saving, clearError: true);
    try {
      await repository.deletePrescription(id);
      final newList = state.prescriptions.where((p) => p.id != id).toList();
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, prescriptions: newList,
          clearError: true);
      _refreshSummary();
      return true;
    } catch (e) {
      state = state.copyWith(
          status: HealthRecordsStatus.loaded, errorMessage: e.toString());
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
