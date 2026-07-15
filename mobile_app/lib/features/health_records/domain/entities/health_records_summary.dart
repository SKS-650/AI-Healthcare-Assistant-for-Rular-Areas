import 'timeline_event.dart';

/// Lightweight summary returned by the dashboard summary endpoint.
class HealthRecordsSummary {
  final bool hasProfile;
  final int medicalHistoryCount;
  final int prescriptionCount;
  final int medicalImageCount;
  final List<TimelineEvent> recentTimeline;

  const HealthRecordsSummary({
    required this.hasProfile,
    required this.medicalHistoryCount,
    required this.prescriptionCount,
    required this.medicalImageCount,
    required this.recentTimeline,
  });

  int get totalRecords =>
      medicalHistoryCount + prescriptionCount + medicalImageCount;
}
