import '../../domain/entities/upload_record.dart';

class UploadRecordModel extends UploadRecord {
  const UploadRecordModel({
    required super.title,
    required super.category,
    required super.doctorName,
    required super.recordDate,
    required super.notes,
  });
}
