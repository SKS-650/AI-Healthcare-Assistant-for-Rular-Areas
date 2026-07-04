import '../repositories/emergency_repository.dart';

class GetEmergencyData {
  final EmergencyRepository repository;

  const GetEmergencyData(this.repository);

  Future<EmergencyData> call() => repository.getEmergencyData();
}
