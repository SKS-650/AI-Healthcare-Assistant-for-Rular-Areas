import '../../domain/entities/ambulance.dart';

class AmbulanceModel extends Ambulance {
  const AmbulanceModel({
    required super.id,
    required super.providerName,
    required super.driverName,
    required super.phoneNumber,
    required super.distanceKm,
    required super.etaMinutes,
    super.available,
  });

  factory AmbulanceModel.fromJson(Map<String, dynamic> json) {
    return AmbulanceModel(
      id: json['id'] as String,
      providerName: json['providerName'] as String,
      driverName: json['driverName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      etaMinutes: json['etaMinutes'] as int,
      available: json['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerName': providerName,
      'driverName': driverName,
      'phoneNumber': phoneNumber,
      'distanceKm': distanceKm,
      'etaMinutes': etaMinutes,
      'available': available,
    };
  }
}
