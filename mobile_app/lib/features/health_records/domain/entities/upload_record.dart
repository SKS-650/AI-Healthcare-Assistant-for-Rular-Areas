class UploadRecord {
  final String title;
  final String category;
  final String doctorName;
  final DateTime recordDate;
  final String notes;

  const UploadRecord({
    required this.title,
    required this.category,
    required this.doctorName,
    required this.recordDate,
    required this.notes,
  });
}
