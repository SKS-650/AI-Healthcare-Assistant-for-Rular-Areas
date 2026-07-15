import '../../domain/entities/health_records_summary.dart';
import 'timeline_event_model.dart';

class HealthSummaryModel extends HealthRecordsSummary {
  const HealthSummaryModel({
    required super.hasProfile,
    required super.medicalHistoryCount,
    required super.prescriptionCount,
    required super.medicalImageCount,
    required super.recentTimeline,
  });

  factory HealthSummaryModel.fromJson(Map<String, dynamic> json) =>
      HealthSummaryModel(
        hasProfile:           json['has_profile'] as bool? ?? false,
        medicalHistoryCount:  json['medical_history_count'] as int? ?? 0,
        prescriptionCount:    json['prescription_count'] as int? ?? 0,
        medicalImageCount:    json['medical_image_count'] as int? ?? 0,
        recentTimeline:       (json['recent_timeline'] as List<dynamic>? ?? [])
            .map((e) => TimelineEventModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
