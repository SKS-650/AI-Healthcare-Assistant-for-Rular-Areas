import '../entities/ambulance.dart';
import '../repositories/emergency_repository.dart';

class GetNearbyAmbulances {
  final EmergencyRepository repository;

  const GetNearbyAmbulances(this.repository);

  Future<List<Ambulance>> call() => repository.getNearbyAmbulances();
}
