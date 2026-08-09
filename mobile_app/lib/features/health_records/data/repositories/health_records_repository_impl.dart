/// Health Records Repository Implementation.
///
/// Uses [HealthRecordsRemoteDataSource] (real HTTP) as primary source.
/// Falls back to [LocalDbService] (Hive) when offline or API fails.
///
/// Write operations go remote first; local cache updated on success.
library;

import '../../../../core/local_db/local_db_service.dart';
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
import '../../domain/entities/upload_record.dart';
import '../../domain/repositories/health_records_repository.dart';
import '../datasources/health_records_dummy_data.dart';
import '../datasources/health_records_remote_datasource.dart';
import '../models/medical_history_model.dart';
import '../models/medical_image_model.dart';
import '../models/medical_profile_model.dart';
import '../models/medical_record_model.dart';

class HealthRecordsRepositoryImpl implements HealthRecordsRepository {
  final _remote = HealthRecordsRemoteDataSource.instance;
  final _local = LocalDbService.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // Legacy records — these use the real backend prescriptions endpoint.
  // getMedicalRecords and getLabReports have no dedicated backend endpoints
  // so they return empty lists (the UI uses medicalHistory/medicalImages
  // which DO have real endpoints).
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<MedicalRecord>> getMedicalRecords() async => const [];

  @override
  Future<List<Prescription>> getPrescriptions() async {
    try {
      return await _remote.getPrescriptions();
    } catch (_) {
      // Offline: no prescription cache — return empty rather than fake data.
      return const [];
    }
  }

  @override
  Future<List<LabReport>> getLabReports() async => const [];

  @override
  Future<List<MedicalTimeline>> getMedicalTimeline() async => const [];

  @override
  Future<List<ReportCategory>> getCategories() async {
    await _delay(50);
    return HealthRecordsDummyData.categories;
  }

  @override
  Future<List<MedicalRecord>> searchRecords(String query) async {
    // No remote search endpoint — search from cached records only.
    return const [];
  }

  @override
  Future<MedicalRecord> uploadDummyRecord(UploadRecord record) async {
    await _delay(400);
    final doctor = HealthRecordsDummyData.doctors.first;
    return MedicalRecordModel(
      id: 'upload-${DateTime.now().millisecondsSinceEpoch}',
      title: record.title,
      category: record.category,
      summary: record.notes.isEmpty ? 'Uploaded report awaiting review.' : record.notes,
      date: record.recordDate,
      doctor: doctor,
      status: 'Uploaded',
      attachments: const ['uploaded-record.pdf'],
      tags: [record.category.toLowerCase(), record.doctorName.toLowerCase()],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical Profile  (remote → local cache fallback)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<MedicalProfile> getMedicalProfile() async {
    try {
      final model = await _remote.getMedicalProfile();
      _local.saveMedicalProfile(model).ignore();
      return model;
    } catch (_) {
      final cached = await _local.loadMedicalProfile();
      if (cached != null) return cached;
      return MedicalProfile.empty('');
    }
  }

  @override
  Future<MedicalProfile> upsertMedicalProfile(MedicalProfile profile) async {
    // Build a concrete MedicalProfileModel without unsafe cast
    final model = MedicalProfileModel(
      id: profile.id,
      userId: profile.userId,
      bloodGroup: profile.bloodGroup,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      bmi: profile.bmi,
      smokingStatus: profile.smokingStatus,
      alcoholStatus: profile.alcoholStatus,
      activityLevel: profile.activityLevel,
      allergies: List<String>.from(profile.allergies),
      chronicDiseases: List<String>.from(profile.chronicDiseases),
      currentMedications: List<String>.from(profile.currentMedications),
      familyHistory: List<String>.from(profile.familyHistory),
      vaccinationHistory: List.from(profile.vaccinationHistory),
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );

    final updated = await _remote.upsertMedicalProfile(model.toJson());
    _local.saveMedicalProfile(updated).ignore();
    return updated;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical History  (remote → local cache fallback)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<MedicalHistoryEntry>> getMedicalHistory({String? category}) async {
    try {
      final remote = await _remote.getMedicalHistory(category: category);
      if (category == null) _local.saveMedicalHistory(remote).ignore();
      return remote;
    } catch (_) {
      final cached = await _local.loadMedicalHistory();
      if (category == null) return cached;
      return cached.where((e) => e.category == category).toList();
    }
  }

  @override
  Future<MedicalHistoryEntry> createMedicalHistory(MedicalHistoryEntry entry) async {
    final model = _toHistoryModel(entry);
    final created = await _remote.createMedicalHistory(model.toJson());
    _local.upsertHistoryEntry(created).ignore();
    return created;
  }

  @override
  Future<MedicalHistoryEntry> updateMedicalHistory(MedicalHistoryEntry entry) async {
    final model = _toHistoryModel(entry);
    final updated = await _remote.updateMedicalHistory(model.id, model.toJson());
    _local.upsertHistoryEntry(updated).ignore();
    return updated;
  }

  @override
  Future<void> deleteMedicalHistory(String id) async {
    await _remote.deleteHistoryEntry(id);
    _local.deleteHistoryEntry(id).ignore();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Extended Prescriptions
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    final json = <String, dynamic>{
      'doctor_name': prescription.doctor.name,
      'hospital_name': prescription.doctor.hospital,
      'diagnosis': prescription.diagnosis,
      'prescription_date': prescription.prescribedAt.toIso8601String(),
      if (prescription.validUntil != null)
        'valid_until': prescription.validUntil!.toIso8601String(),
      'medicines': prescription.medicines
          .map((m) => {
                'name': m.name,
                'dose': m.dose,
                'frequency': m.frequency,
                'duration': m.duration,
              })
          .toList(),
      'instructions': prescription.instructions,
      if (prescription.notes != null) 'notes': prescription.notes,
    };
    return _remote.createPrescription(json);
  }

  @override
  Future<void> deletePrescription(String id) => _remote.deletePrescription(id);

  // ─────────────────────────────────────────────────────────────────────────
  // Medical Images  (remote → local cache fallback)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<MedicalImageRecord>> getMedicalImages({String? imageType}) async {
    try {
      final remote = await _remote.getMedicalImages(imageType: imageType);
      if (imageType == null) _local.saveMedicalImages(remote).ignore();
      return remote;
    } catch (_) {
      final cached = await _local.loadMedicalImages();
      if (imageType == null) return cached;
      return cached.where((i) => i.imageType == imageType).toList();
    }
  }

  @override
  Future<MedicalImageRecord> uploadMedicalImage(MedicalImageRecord image) async {
    final model = _toImageModel(image);
    final created = await _remote.createMedicalImage(model.toJson());
    return created;
  }

  @override
  Future<void> deleteMedicalImage(String id) async {
    await _remote.deleteMedicalImage(id);
    _local.deleteMedicalImage(id).ignore();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Unified Timeline  (remote → local cache fallback)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<TimelineEvent>> getTimelineEvents({
    String? eventType,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final remote = await _remote.getTimeline(
        eventType: eventType, limit: limit, offset: offset);
      if (eventType == null && offset == 0) {
        _local.saveTimelineEvents(remote).ignore();
      }
      return remote;
    } catch (_) {
      final cached = await _local.loadTimelineEvents();
      var result = cached;
      if (eventType != null) {
        result = result.where((e) => e.eventType == eventType).toList();
      }
      return result.skip(offset).take(limit).toList();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dashboard Summary
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<HealthRecordsSummary> getSummary() async {
    try {
      return await _remote.getSummary();
    } catch (_) {
      // Build a lightweight local summary from caches
      final history = await _local.loadMedicalHistory();
      final images = await _local.loadMedicalImages();
      final timeline = await _local.loadTimelineEvents();
      final profile = await _local.loadMedicalProfile();
      return HealthRecordsSummary(
        hasProfile: profile != null,
        medicalHistoryCount: history.length,
        prescriptionCount: 0,
        medicalImageCount: images.length,
        recentTimeline: timeline.take(5).toList(),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  MedicalHistoryModel _toHistoryModel(MedicalHistoryEntry e) {
    if (e is MedicalHistoryModel) return e;
    return MedicalHistoryModel(
      id: e.id,
      userId: e.userId,
      diseaseName: e.diseaseName,
      category: e.category,
      diagnosisDate: e.diagnosisDate,
      status: e.status,
      doctorName: e.doctorName,
      hospitalName: e.hospitalName,
      notes: e.notes,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  MedicalImageModel _toImageModel(MedicalImageRecord i) {
    if (i is MedicalImageModel) return i;
    return MedicalImageModel(
      id: i.id,
      userId: i.userId,
      title: i.title,
      imageType: i.imageType,
      description: i.description,
      bodyPart: i.bodyPart,
      doctorName: i.doctorName,
      hospitalName: i.hospitalName,
      scanDate: i.scanDate,
      tags: i.tags,
      fileUrl: i.fileUrl,
      fileOriginalName: i.fileOriginalName,
      fileSizeBytes: i.fileSizeBytes,
      createdAt: i.createdAt,
    );
  }

  static Future<void> _delay(int ms) =>
      Future.delayed(Duration(milliseconds: ms));
}
