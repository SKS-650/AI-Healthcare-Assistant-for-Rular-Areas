import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/health_records_repository_impl.dart';
import '../../domain/repositories/health_records_repository.dart';
import '../../domain/usecases/get_lab_reports.dart';
import '../../domain/usecases/get_medical_records.dart';
import '../../domain/usecases/get_medical_timeline.dart';
import '../../domain/usecases/get_prescriptions.dart';
import '../../domain/usecases/search_records.dart';
import '../../domain/usecases/upload_dummy_record.dart';
import '../controllers/health_records_controller.dart';
import '../controllers/health_records_state.dart';

final healthRecordsRepositoryProvider = Provider<HealthRecordsRepository>((
  ref,
) {
  return HealthRecordsRepositoryImpl();
});

final healthRecordsControllerProvider =
    StateNotifierProvider<HealthRecordsController, HealthRecordsState>((ref) {
      final repository = ref.watch(healthRecordsRepositoryProvider);
      return HealthRecordsController(
        getMedicalRecords: GetMedicalRecords(repository),
        getPrescriptions: GetPrescriptions(repository),
        getLabReports: GetLabReports(repository),
        getMedicalTimeline: GetMedicalTimeline(repository),
        uploadDummyRecord: UploadDummyRecord(repository),
        searchRecords: SearchRecords(repository),
        repository: repository,
      );
    });
