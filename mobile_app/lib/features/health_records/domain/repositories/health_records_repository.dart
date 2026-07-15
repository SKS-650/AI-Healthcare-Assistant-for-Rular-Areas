import '../entities/health_records_summary.dart';
import '../entities/lab_report.dart';
import '../entities/medical_history_entry.dart';
import '../entities/medical_image_record.dart';
import '../entities/medical_profile.dart';
import '../entities/medical_record.dart';
import '../entities/medical_timeline.dart';
import '../entities/prescription.dart';
import '../entities/report_category.dart';
import '../entities/timeline_event.dart';
import '../entities/upload_record.dart';

abstract class HealthRecordsRepository {
  // ── Legacy records (kept for backwards compatibility) ─────────────────────
  Future<List<MedicalRecord>> getMedicalRecords();
  Future<List<Prescription>> getPrescriptions();
  Future<List<LabReport>> getLabReports();
  Future<List<MedicalTimeline>> getMedicalTimeline();
  Future<List<ReportCategory>> getCategories();
  Future<MedicalRecord> uploadDummyRecord(UploadRecord record);
  Future<List<MedicalRecord>> searchRecords(String query);

  // ── Medical Profile ───────────────────────────────────────────────────────
  Future<MedicalProfile> getMedicalProfile();
  Future<MedicalProfile> upsertMedicalProfile(MedicalProfile profile);

  // ── Medical History ───────────────────────────────────────────────────────
  Future<List<MedicalHistoryEntry>> getMedicalHistory({String? category});
  Future<MedicalHistoryEntry> createMedicalHistory(MedicalHistoryEntry entry);
  Future<MedicalHistoryEntry> updateMedicalHistory(MedicalHistoryEntry entry);
  Future<void> deleteMedicalHistory(String id);

  // ── Extended Prescriptions ────────────────────────────────────────────────
  Future<Prescription> createPrescription(Prescription prescription);
  Future<void> deletePrescription(String id);

  // ── Medical Images ────────────────────────────────────────────────────────
  Future<List<MedicalImageRecord>> getMedicalImages({String? imageType});
  Future<MedicalImageRecord> uploadMedicalImage(MedicalImageRecord image);
  Future<void> deleteMedicalImage(String id);

  // ── Unified Timeline ──────────────────────────────────────────────────────
  Future<List<TimelineEvent>> getTimelineEvents({
    String? eventType,
    int limit,
    int offset,
  });

  // ── Dashboard Summary ─────────────────────────────────────────────────────
  Future<HealthRecordsSummary> getSummary();
}
