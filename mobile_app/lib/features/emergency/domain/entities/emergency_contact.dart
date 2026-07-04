class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relation;
  final bool isPrimary;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relation,
    this.isPrimary = false,
  });
}
