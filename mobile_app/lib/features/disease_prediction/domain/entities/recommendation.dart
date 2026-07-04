import 'hospital.dart';
import 'medicine.dart';
import 'prevention.dart';
import 'treatment.dart';

class Recommendation {
  final List<Treatment> treatments;
  final List<Medicine> medicines;
  final List<Prevention> preventions;
  final List<Hospital> nearbyHospitals;
  final bool shouldVisitDoctor;
  final String doctorVisitReason;

  const Recommendation({
    required this.treatments,
    required this.medicines,
    required this.preventions,
    required this.nearbyHospitals,
    required this.shouldVisitDoctor,
    required this.doctorVisitReason,
  });
}
