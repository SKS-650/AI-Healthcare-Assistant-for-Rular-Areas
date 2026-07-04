import '../entities/location.dart';
import '../entities/route.dart';
import '../repositories/nearby_healthcare_repository.dart';

class GetRoute {
  final NearbyHealthcareRepository repository;

  const GetRoute(this.repository);

  Future<HealthcareRoute> call(Location destination) {
    return repository.getRoute(destination);
  }
}
