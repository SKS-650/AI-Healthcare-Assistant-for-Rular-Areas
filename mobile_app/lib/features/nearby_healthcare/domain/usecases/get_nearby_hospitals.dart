import '../entities/hospital.dart';
import '../repositories/nearby_healthcare_repository.dart';

class GetNearbyHospitals {
  final NearbyHealthcareRepository repository;

  const GetNearbyHospitals(this.repository);

  Future<List<Hospital>> call() {
    return repository.getNearbyHospitals();
  }
}
