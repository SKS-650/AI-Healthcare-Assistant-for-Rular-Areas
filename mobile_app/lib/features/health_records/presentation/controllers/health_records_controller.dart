import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_record.dart';
import '../../domain/repositories/health_records_repository.dart';
import '../../domain/usecases/get_lab_reports.dart';
import '../../domain/usecases/get_medical_records.dart';
import '../../domain/usecases/get_medical_timeline.dart';
import '../../domain/usecases/get_prescriptions.dart';
import '../../domain/usecases/search_records.dart';
import '../../domain/usecases/upload_dummy_record.dart';
import 'health_records_state.dart';

class HealthRecordsController extends StateNotifier<HealthRecordsState> {
  final GetMedicalRecords getMedicalRecords;
  final GetPrescriptions getPrescriptions;
  final GetLabReports getLabReports;
  final GetMedicalTimeline getMedicalTimeline;
  final UploadDummyRecord uploadDummyRecord;
  final SearchRecords searchRecords;
  final HealthRecordsRepository repository;

  HealthRecordsController({
    required this.getMedicalRecords,
    required this.getPrescriptions,
    required this.getLabReports,
    required this.getMedicalTimeline,
    required this.uploadDummyRecord,
    required this.searchRecords,
    required this.repository,
  }) : super(const HealthRecordsState()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = state.copyWith(
      status: HealthRecordsStatus.loading,
      clearError: true,
    );

    try {
      final records = await getMedicalRecords();
      final prescriptions = await getPrescriptions();
      final labReports = await getLabReports();
      final timeline = await getMedicalTimeline();
      final categories = await repository.getCategories();

      state = state.copyWith(
        status: HealthRecordsStatus.loaded,
        records: records,
        prescriptions: prescriptions,
        labReports: labReports,
        timeline: timeline,
        categories: categories,
        searchResults: records,
      );
    } catch (error) {
      state = state.copyWith(
        status: HealthRecordsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> search(String query) async {
    try {
      final results = await searchRecords(query);
      state = state.copyWith(searchQuery: query, searchResults: results);
    } catch (error) {
      state = state.copyWith(
        status: HealthRecordsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<bool> upload(UploadRecord record) async {
    state = state.copyWith(
      status: HealthRecordsStatus.uploading,
      clearError: true,
    );

    try {
      await uploadDummyRecord(record);
      await loadRecords();
      return true;
    } catch (error) {
      state = state.copyWith(
        status: HealthRecordsStatus.failure,
        errorMessage: error.toString(),
      );
      return false;
    }
  }
}
