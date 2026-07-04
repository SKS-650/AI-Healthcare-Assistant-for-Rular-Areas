import '../entities/clinic.dart';
import '../repositories/nearby_healthcare_repository.dart';

class GetNearbyClinics {
  final NearbyHealthcareRepository repository;

  const GetNearbyClinics(this.repository);

  Future<List<Clinic>> call() {
    return repository.getNearbyClinics();
  }
}
