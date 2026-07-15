/// A medical image / scan record (X-Ray, MRI, CT scan, blood report, ECG, skin).
/// image_type: xray | mri | ct_scan | blood_report | ecg | skin | other
class MedicalImageRecord {
  final String id;
  final String userId;
  final String title;
  final String imageType;
  final String? description;
  final String? bodyPart;
  final String? doctorName;
  final String? hospitalName;
  final DateTime? scanDate;
  final List<String> tags;
  final String? fileUrl;
  final String? fileOriginalName;
  final int? fileSizeBytes;
  final DateTime createdAt;

  const MedicalImageRecord({
    required this.id,
    required this.userId,
    required this.title,
    required this.imageType,
    this.description,
    this.bodyPart,
    this.doctorName,
    this.hospitalName,
    this.scanDate,
    required this.tags,
    this.fileUrl,
    this.fileOriginalName,
    this.fileSizeBytes,
    required this.createdAt,
  });

  String get typeLabel {
    const labels = {
      'xray':         'X-Ray',
      'mri':          'MRI Scan',
      'ct_scan':      'CT Scan',
      'blood_report': 'Blood Report',
      'ecg':          'ECG',
      'skin':         'Skin Image',
      'other':        'Other',
    };
    return labels[imageType] ?? imageType.toUpperCase();
  }

  String get typeEmoji {
    const emojis = {
      'xray':         '🩻',
      'mri':          '🧠',
      'ct_scan':      '🔬',
      'blood_report': '🩸',
      'ecg':          '❤️',
      'skin':         '🫀',
      'other':        '📄',
    };
    return emojis[imageType] ?? '📄';
  }

  String get fileSizeFormatted {
    final bytes = fileSizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
