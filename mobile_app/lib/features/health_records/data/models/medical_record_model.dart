import '../../domain/entities/doctor.dart';
import '../../domain/entities/medical_record.dart';

class MedicalRecordModel extends MedicalRecord {
  const MedicalRecordModel({
    required super.id,
    required super.title,
    required super.category,
    required super.summary,
    required super.date,
    required super.doctor,
    required super.status,
    required super.attachments,
    required super.tags,
  });

  MedicalRecordModel copyWith({
    String? id,
    String? title,
    String? category,
    String? summary,
    DateTime? date,
    Doctor? doctor,
    String? status,
    List<String>? attachments,
    List<String>? tags,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      date: date ?? this.date,
      doctor: doctor ?? this.doctor,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
    );
  }
}
