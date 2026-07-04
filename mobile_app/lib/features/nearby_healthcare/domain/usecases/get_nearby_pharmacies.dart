import '../entities/pharmacy.dart';
import '../repositories/nearby_healthcare_repository.dart';

class GetNearbyPharmacies {
  final NearbyHealthcareRepository repository;

  const GetNearbyPharmacies(this.repository);

  Future<List<Pharmacy>> call() {
    return repository.getNearbyPharmacies();
  }
}
