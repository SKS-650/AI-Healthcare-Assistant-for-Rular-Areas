import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/health_records_repository_impl.dart';
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
import '../controllers/health_records_controller.dart';
import '../controllers/health_records_state.dart';

final healthRecordsRepositoryProvider = Provider<HealthRecordsRepository>(
  (_) => HealthRecordsRepositoryImpl(),
);

final healthRecordsControllerProvider =
    StateNotifierProvider<HealthRecordsController, HealthRecordsState>((ref) {
  final repo = ref.watch(healthRecordsRepositoryProvider);
  return HealthRecordsController(
    getMedicalRecords:    GetMedicalRecords(repo),
    getPrescriptions:     GetPrescriptions(repo),
    getLabReports:        GetLabReports(repo),
    getMedicalTimeline:   GetMedicalTimeline(repo),
    uploadDummyRecord:    UploadDummyRecord(repo),
    searchRecords:        SearchRecords(repo),
    getMedicalProfile:    GetMedicalProfile(repo),
    upsertMedicalProfile: UpsertMedicalProfile(repo),
    getMedicalHistory:    GetMedicalHistory(repo),
    createMedicalHistory: CreateMedicalHistory(repo),
    updateMedicalHistory: UpdateMedicalHistory(repo),
    deleteMedicalHistory: DeleteMedicalHistory(repo),
    getMedicalImages:     GetMedicalImages(repo),
    uploadMedicalImage:   UploadMedicalImage(repo),
    getTimelineEvents:    GetTimelineEvents(repo),
    getHealthSummary:     GetHealthSummary(repo),
    repository:           repo,
  );
});
