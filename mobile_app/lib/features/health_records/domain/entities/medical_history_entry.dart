/// A single entry in a user's medical history.
/// category: current | past | surgery | allergy | chronic | family
/// status:   active  | resolved | managed
class MedicalHistoryEntry {
  final String id;
  final String userId;
  final String diseaseName;
  final String category;
  final DateTime? diagnosisDate;
  final String status;
  final String? doctorName;
  final String? hospitalName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicalHistoryEntry({
    required this.id,
    required this.userId,
    required this.diseaseName,
    required this.category,
    this.diagnosisDate,
    required this.status,
    this.doctorName,
    this.hospitalName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get categoryLabel {
    const labels = {
      'current':  'Current Condition',
      'past':     'Past Condition',
      'surgery':  'Surgery',
      'allergy':  'Allergy',
      'chronic':  'Chronic Condition',
      'family':   'Family History',
    };
    return labels[category] ?? category;
  }

  String get categoryEmoji {
    const emojis = {
      'current':  '🩺',
      'past':     '📋',
      'surgery':  '🏥',
      'allergy':  '⚠️',
      'chronic':  '💊',
      'family':   '👨‍👩‍👧',
    };
    return emojis[category] ?? '📋';
  }

  bool get isActive => status == 'active';
}
