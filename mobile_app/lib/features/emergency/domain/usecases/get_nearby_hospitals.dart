import '../entities/hospital.dart';
import '../repositories/emergency_repository.dart';

class GetNearbyHospitals {
  final EmergencyRepository repository;

  const GetNearbyHospitals(this.repository);

  Future<List<Hospital>> call() => repository.getNearbyHospitals();
}
