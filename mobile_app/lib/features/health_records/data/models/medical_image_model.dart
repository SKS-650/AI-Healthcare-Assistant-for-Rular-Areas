import '../../domain/entities/medical_image_record.dart';

class MedicalImageModel extends MedicalImageRecord {
  const MedicalImageModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.imageType,
    super.description,
    super.bodyPart,
    super.doctorName,
    super.hospitalName,
    super.scanDate,
    required super.tags,
    super.fileUrl,
    super.fileOriginalName,
    super.fileSizeBytes,
    required super.createdAt,
  });

  factory MedicalImageModel.fromJson(Map<String, dynamic> json) =>
      MedicalImageModel(
        id:               json['id'] as String,
        userId:           json['user_id'] as String? ?? '',
        title:            json['title'] as String,
        imageType:        json['image_type'] as String? ?? 'other',
        description:      json['description'] as String?,
        bodyPart:         json['body_part'] as String?,
        doctorName:       json['doctor_name'] as String?,
        hospitalName:     json['hospital_name'] as String?,
        scanDate:         json['scan_date'] != null
            ? DateTime.parse(json['scan_date'] as String)
            : null,
        tags:             (json['tags'] as List<dynamic>? ?? [])
            .map((t) => t.toString())
            .toList(),
        fileUrl:          json['file_url'] as String?,
        fileOriginalName: json['file_original_name'] as String?,
        fileSizeBytes:    json['file_size_bytes'] as int?,
        createdAt:        DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'title':      title,
        'image_type': imageType,
        if (description != null)  'description':   description,
        if (bodyPart != null)     'body_part':      bodyPart,
        if (doctorName != null)   'doctor_name':    doctorName,
        if (hospitalName != null) 'hospital_name':  hospitalName,
        if (scanDate != null)     'scan_date':      scanDate!.toIso8601String(),
        'tags':       tags,
      };
}
