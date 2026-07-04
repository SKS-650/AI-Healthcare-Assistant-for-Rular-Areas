import '../../domain/entities/medical_timeline.dart';

class MedicalTimelineModel extends MedicalTimeline {
  const MedicalTimelineModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.occurredAt,
    required super.doctorName,
  });
}
