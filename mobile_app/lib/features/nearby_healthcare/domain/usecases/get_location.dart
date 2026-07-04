import '../entities/location.dart';
import '../repositories/nearby_healthcare_repository.dart';

class GetLocation {
  final NearbyHealthcareRepository repository;

  const GetLocation(this.repository);

  Future<Location> call() {
    return repository.getLocation();
  }
}
