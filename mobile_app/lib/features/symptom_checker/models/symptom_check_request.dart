/// Model for symptom check request
class SymptomCheckRequest {
  final List<String> symptoms;
  final int age;
  final String gender;
  final double? weight;
  final double? height;
  final int? duration;
  final int severity;
  final List<String>? existingDiseases;
  final List<String>? medications;
  final List<String>? allergies;
  final bool pregnancyStatus;

  SymptomCheckRequest({
    required this.symptoms,
    required this.age,
    required this.gender,
    this.weight,
    this.height,
    this.duration,
    this.severity = 2,
    this.existingDiseases,
    this.medications,
    this.allergies,
    this.pregnancyStatus = false,
  });

  Map<String, dynamic> toJson() => {
        'symptoms': symptoms,
        'age': age,
        'gender': gender,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (duration != null) 'duration': duration,
        'severity': severity,
        if (existingDiseases != null) 'existing_diseases': existingDiseases,
        if (medications != null) 'medications': medications,
        if (allergies != null) 'allergies': allergies,
        'pregnancy_status': pregnancyStatus,
      };
}
