import '../../domain/entities/recommendation.dart';
import 'hospital_model.dart';
import 'medicine_model.dart';
import 'prevention_model.dart';
import 'treatment_model.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.treatments,
    required super.medicines,
    required super.preventions,
    required super.nearbyHospitals,
    required super.shouldVisitDoctor,
    required super.doctorVisitReason,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      treatments: (json['treatments'] as List)
          .map((item) => TreatmentModel.fromJson(item))
          .toList(),
      medicines: (json['medicines'] as List)
          .map((item) => MedicineModel.fromJson(item))
          .toList(),
      preventions: (json['preventions'] as List)
          .map((item) => PreventionModel.fromJson(item))
          .toList(),
      nearbyHospitals: (json['nearbyHospitals'] as List)
          .map((item) => HospitalModel.fromJson(item))
          .toList(),
      shouldVisitDoctor: json['shouldVisitDoctor'] as bool,
      doctorVisitReason: json['doctorVisitReason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treatments': treatments
          .map((item) => (item as TreatmentModel).toJson())
          .toList(),
      'medicines': medicines
          .map((item) => (item as MedicineModel).toJson())
          .toList(),
      'preventions': preventions
          .map((item) => (item as PreventionModel).toJson())
          .toList(),
      'nearbyHospitals': nearbyHospitals
          .map((item) => (item as HospitalModel).toJson())
          .toList(),
      'shouldVisitDoctor': shouldVisitDoctor,
      'doctorVisitReason': doctorVisitReason,
    };
  }
}
