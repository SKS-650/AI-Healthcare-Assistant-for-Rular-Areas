import '../entities/clinic.dart';
import '../entities/hospital.dart';
import '../entities/location.dart';
import '../entities/pharmacy.dart';
import '../entities/route.dart';

abstract class NearbyHealthcareRepository {
  Future<List<Hospital>> getNearbyHospitals();
  Future<List<Clinic>> getNearbyClinics();
  Future<List<Pharmacy>> getNearbyPharmacies();
  Future<Location> getLocation();
  Future<HealthcareRoute> getRoute(Location destination);
}
