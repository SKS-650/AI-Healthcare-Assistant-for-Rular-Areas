import '../entities/lab_report.dart';
import '../entities/medical_record.dart';
import '../entities/medical_timeline.dart';
import '../entities/prescription.dart';
import '../entities/report_category.dart';
import '../entities/upload_record.dart';

abstract class HealthRecordsRepository {
  Future<List<MedicalRecord>> getMedicalRecords();
  Future<List<Prescription>> getPrescriptions();
  Future<List<LabReport>> getLabReports();
  Future<List<MedicalTimeline>> getMedicalTimeline();
  Future<List<ReportCategory>> getCategories();
  Future<MedicalRecord> uploadDummyRecord(UploadRecord record);
  Future<List<MedicalRecord>> searchRecords(String query);
}
