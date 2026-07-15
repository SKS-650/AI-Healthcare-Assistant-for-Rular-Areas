import '../entities/timeline_event.dart';
import '../repositories/health_records_repository.dart';

class GetTimelineEvents {
  final HealthRecordsRepository repository;
  const GetTimelineEvents(this.repository);

  Future<List<TimelineEvent>> call({
    String? eventType,
    int limit = 50,
    int offset = 0,
  }) =>
      repository.getTimelineEvents(
        eventType: eventType,
        limit: limit,
        offset: offset,
      );
}
