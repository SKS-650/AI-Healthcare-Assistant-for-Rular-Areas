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
import '../models/medical_history_model.dart';
import '../models/medical_image_model.dart';
import '../models/medical_profile_model.dart';
import '../models/medical_record_model.dart';

/// Full repository implementation using local dummy data.
///
/// In production swap each method body to call a RemoteDataSource
/// (HTTP client) with a local Hive cache fallback — exactly the same
/// pattern used in the emergency feature.
class HealthRecordsRepositoryImpl implements HealthRecordsRepository {
  // Mutable in-memory stores so add/delete survive the session.
  final List<MedicalRecordModel> _records =
      [...HealthRecordsDummyData.records];
  final List<MedicalHistoryModel> _history =
      [...HealthRecordsDummyData.medicalHistory];
  final List<MedicalImageModel> _images =
      [...HealthRecordsDummyData.medicalImages];
  MedicalProfileModel _profile = HealthRecordsDummyData.medicalProfile;

  // ─────────────────────────────────────────────────────────────────────────
  // Legacy records
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<MedicalRecord>> getMedicalRecords() async {
    await _delay(250);
    return List.unmodifiable(_records);
  }

  @override
  Future<List<Prescription>> getPrescriptions() async {
    await _delay(250);
    return HealthRecordsDummyData.prescriptions;
  }

  @override
  Future<List<LabReport>> getLabReports() async {
    await _delay(250);
    return HealthRecordsDummyData.labReports;
  }

  @override
  Future<List<MedicalTimeline>> getMedicalTimeline() async {
    await _delay(250);
    final uploaded = _records
        .where((r) => r.id.startsWith('upload-'))
        .map((r) => MedicalTimeline(
              id: 't-${r.id}',
              title: r.title,
              description: r.summary,
              type: r.category,
              occurredAt: r.date,
              doctorName: r.doctor.name,
            ));
    return [...uploaded, ...HealthRecordsDummyData.timeline()]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  @override
  Future<List<ReportCategory>> getCategories() async {
    await _delay(150);
    return HealthRecordsDummyData.categories;
  }

  @override
  Future<List<MedicalRecord>> searchRecords(String query) async {
    await _delay(150);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_records);
    return _records.where((r) {
      final text = [r.title, r.category, r.summary, r.doctor.name, ...r.tags]
          .join(' ')
          .toLowerCase();
      return text.contains(q);
    }).toList();
  }

  @override
  Future<MedicalRecord> uploadDummyRecord(UploadRecord record) async {
    await _delay(600);
    final doctor = HealthRecordsDummyData.doctors.first;
    final uploaded = MedicalRecordModel(
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
    _records.insert(0, uploaded);
    return uploaded;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical Profile
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<MedicalProfile> getMedicalProfile() async {
    await _delay(200);
    return _profile;
  }

  @override
  Future<MedicalProfile> upsertMedicalProfile(MedicalProfile profile) async {
    await _delay(400);
    _profile = MedicalProfileModel(
      id:                  profile.id.isEmpty ? 'mp-local' : profile.id,
      userId:              profile.userId,
      bloodGroup:          profile.bloodGroup,
      heightCm:            profile.heightCm,
      weightKg:            profile.weightKg,
      bmi:                 profile.bmi,
      smokingStatus:       profile.smokingStatus,
      alcoholStatus:       profile.alcoholStatus,
      activityLevel:       profile.activityLevel,
      allergies:           profile.allergies,
      chronicDiseases:     profile.chronicDiseases,
      currentMedications:  profile.currentMedications,
      familyHistory:       profile.familyHistory,
      vaccinationHistory:  profile.vaccinationHistory,
      createdAt:           profile.createdAt,
      updatedAt:           DateTime.now(),
    );
    return _profile;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical History
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<MedicalHistoryEntry>> getMedicalHistory({
    String? category,
  }) async {
    await _delay(200);
    if (category == null) return List.unmodifiable(_history);
    return _history.where((e) => e.category == category).toList();
  }

  @override
  Future<MedicalHistoryEntry> createMedicalHistory(
      MedicalHistoryEntry entry) async {
    await _delay(400);
    final model = MedicalHistoryModel(
      id:            'mh-${DateTime.now().millisecondsSinceEpoch}',
      userId:        entry.userId,
      diseaseName:   entry.diseaseName,
      category:      entry.category,
      diagnosisDate: entry.diagnosisDate,
      status:        entry.status,
      doctorName:    entry.doctorName,
      hospitalName:  entry.hospitalName,
      notes:         entry.notes,
      createdAt:     DateTime.now(),
      updatedAt:     DateTime.now(),
    );
    _history.insert(0, model);
    return model;
  }

  @override
  Future<MedicalHistoryEntry> updateMedicalHistory(
      MedicalHistoryEntry entry) async {
    await _delay(400);
    final idx = _history.indexWhere((e) => e.id == entry.id);
    final model = MedicalHistoryModel(
      id:            entry.id,
      userId:        entry.userId,
      diseaseName:   entry.diseaseName,
      category:      entry.category,
      diagnosisDate: entry.diagnosisDate,
      status:        entry.status,
      doctorName:    entry.doctorName,
      hospitalName:  entry.hospitalName,
      notes:         entry.notes,
      createdAt:     entry.createdAt,
      updatedAt:     DateTime.now(),
    );
    if (idx >= 0) { _history[idx] = model; } else { _history.insert(0, model); }
    return model;
  }

  @override
  Future<void> deleteMedicalHistory(String id) async {
    await _delay(300);
    _history.removeWhere((e) => e.id == id);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Extended Prescriptions
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    await _delay(500);
    // Already modelled in dummy list — return as-is
    return prescription;
  }

  @override
  Future<void> deletePrescription(String id) async {
    await _delay(300);
    // Remove from dummy list not implemented (prescriptions list is const)
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical Images
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<MedicalImageRecord>> getMedicalImages({
    String? imageType,
  }) async {
    await _delay(200);
    if (imageType == null) return List.unmodifiable(_images);
    return _images.where((i) => i.imageType == imageType).toList();
  }

  @override
  Future<MedicalImageRecord> uploadMedicalImage(
      MedicalImageRecord image) async {
    await _delay(600);
    final model = MedicalImageModel(
      id:               'img-${DateTime.now().millisecondsSinceEpoch}',
      userId:           image.userId,
      title:            image.title,
      imageType:        image.imageType,
      description:      image.description,
      bodyPart:         image.bodyPart,
      doctorName:       image.doctorName,
      hospitalName:     image.hospitalName,
      scanDate:         image.scanDate,
      tags:             image.tags,
      fileUrl:          image.fileUrl,
      fileOriginalName: image.fileOriginalName,
      fileSizeBytes:    image.fileSizeBytes,
      createdAt:        DateTime.now(),
    );
    _images.insert(0, model);
    return model;
  }

  @override
  Future<void> deleteMedicalImage(String id) async {
    await _delay(300);
    _images.removeWhere((i) => i.id == id);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Unified Timeline
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<TimelineEvent>> getTimelineEvents({
    String? eventType,
    int limit = 50,
    int offset = 0,
  }) async {
    await _delay(200);
    var events = HealthRecordsDummyData.timelineEvents();
    if (eventType != null) {
      events = events.where((e) => e.eventType == eventType).toList();
    }
    return events.skip(offset).take(limit).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dashboard Summary
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<HealthRecordsSummary> getSummary() async {
    await _delay(200);
    return HealthRecordsDummyData.summary();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _delay(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));
}
