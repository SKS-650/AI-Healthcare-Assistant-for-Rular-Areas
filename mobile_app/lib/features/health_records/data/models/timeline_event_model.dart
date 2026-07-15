import '../../domain/entities/timeline_event.dart';

class TimelineEventModel extends TimelineEvent {
  const TimelineEventModel({
    required super.id,
    required super.eventType,
    required super.title,
    super.description,
    super.referenceId,
    super.iconEmoji,
    required super.eventDate,
    required super.createdAt,
  });

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) =>
      TimelineEventModel(
        id:          json['id'] as String,
        eventType:   json['event_type'] as String,
        title:       json['title'] as String,
        description: json['description'] as String?,
        referenceId: json['reference_id'] as String?,
        iconEmoji:   json['icon_emoji'] as String?,
        eventDate:   DateTime.parse(json['event_date'] as String),
        createdAt:   DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toLocalJson() => {
        'id':          id,
        'event_type':  eventType,
        'title':       title,
        'description': description,
        'reference_id': referenceId,
        'icon_emoji':  iconEmoji,
        'event_date':  eventDate.toIso8601String(),
        'created_at':  createdAt.toIso8601String(),
      };
}
