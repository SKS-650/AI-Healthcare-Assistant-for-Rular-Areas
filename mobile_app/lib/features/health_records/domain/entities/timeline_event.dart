/// A unified timeline event combining all medical record types.
/// event_type: medical_history | prescription | medical_image |
///             symptom_assessment | chat_conversation | emergency_assessment
class TimelineEvent {
  final String id;
  final String eventType;
  final String title;
  final String? description;
  final String? referenceId;
  final String? iconEmoji;
  final DateTime eventDate;
  final DateTime createdAt;

  const TimelineEvent({
    required this.id,
    required this.eventType,
    required this.title,
    this.description,
    this.referenceId,
    this.iconEmoji,
    required this.eventDate,
    required this.createdAt,
  });

  String get emoji => iconEmoji ?? _defaultEmoji;

  String get _defaultEmoji {
    const map = {
      'medical_history':      '🩺',
      'prescription':         '💊',
      'medical_image':        '🩻',
      'symptom_assessment':   '🤒',
      'chat_conversation':    '💬',
      'emergency_assessment': '🚨',
    };
    return map[eventType] ?? '📋';
  }

  String get typeLabel {
    const labels = {
      'medical_history':      'Medical History',
      'prescription':         'Prescription',
      'medical_image':        'Medical Image',
      'symptom_assessment':   'Symptom Check',
      'chat_conversation':    'AI Consultation',
      'emergency_assessment': 'Emergency',
    };
    return labels[eventType] ?? 'Health Event';
  }
}
