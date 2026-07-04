import '../../domain/entities/lab_report.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/medical_timeline.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/entities/report_category.dart';
import '../../domain/entities/upload_record.dart';
import '../../domain/repositories/health_records_repository.dart';
import '../datasources/health_records_dummy_data.dart';
import '../models/medical_record_model.dart';

class HealthRecordsRepositoryImpl implements HealthRecordsRepository {
  final List<MedicalRecordModel> _records = [...HealthRecordsDummyData.records];

  @override
  Future<List<MedicalRecord>> getMedicalRecords() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_records);
  }

  @override
  Future<List<Prescription>> getPrescriptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return HealthRecordsDummyData.prescriptions;
  }

  @override
  Future<List<LabReport>> getLabReports() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return HealthRecordsDummyData.labReports;
  }

  @override
  Future<List<MedicalTimeline>> getMedicalTimeline() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final uploaded = _records
        .where((record) => record.id.startsWith('upload-'))
        .map(
          (record) => MedicalTimeline(
            id: 't-${record.id}',
            title: record.title,
            description: record.summary,
            type: record.category,
            occurredAt: record.date,
            doctorName: record.doctor.name,
          ),
        );
    return [...uploaded, ...HealthRecordsDummyData.timeline()]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  @override
  Future<List<ReportCategory>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return HealthRecordsDummyData.categories;
  }

  @override
  Future<List<MedicalRecord>> searchRecords(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return List.unmodifiable(_records);

    return _records.where((record) {
      final searchable = [
        record.title,
        record.category,
        record.summary,
        record.doctor.name,
        ...record.tags,
      ].join(' ').toLowerCase();
      return searchable.contains(normalized);
    }).toList();
  }

  @override
  Future<MedicalRecord> uploadDummyRecord(UploadRecord record) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final doctor = HealthRecordsDummyData.doctors.first;
    final uploaded = MedicalRecordModel(
      id: 'upload-${DateTime.now().millisecondsSinceEpoch}',
      title: record.title,
      category: record.category,
      summary: record.notes.isEmpty
          ? 'Uploaded report awaiting review.'
          : record.notes,
      date: record.recordDate,
      doctor: doctor,
      status: 'Uploaded',
      attachments: const ['uploaded-record.pdf'],
      tags: [record.category.toLowerCase(), record.doctorName.toLowerCase()],
    );
    _records.insert(0, uploaded);
    return uploaded;
  }
}
