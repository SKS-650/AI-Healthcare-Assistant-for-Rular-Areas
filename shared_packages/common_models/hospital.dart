class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    this.address,
    this.phone,
  });

  final String id;
  final String name;
  final String? address;
  final String? phone;
}
