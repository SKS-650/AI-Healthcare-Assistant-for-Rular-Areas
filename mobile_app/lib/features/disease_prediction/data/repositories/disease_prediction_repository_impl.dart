import '../../domain/entities/disease.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/entities/prevention.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/treatment.dart';
import '../../domain/repositories/disease_prediction_repository.dart';
import '../datasources/disease_prediction_dummy_data.dart';
import '../datasources/disease_prediction_remote_datasource.dart';
import '../models/disease_prediction_api_models.dart';
import '../models/prediction_result_model.dart';

class DiseasePredictionRepositoryImpl implements DiseasePredictionRepository {
  final DiseasePredictionRemoteDataSource remoteDataSource;

  /// In-memory history (persisted for the session).
  final List<PredictionResult> _history =
      DiseasePredictionDummyData.initialHistory();

  DiseasePredictionRepositoryImpl({required this.remoteDataSource});

  // ── Main prediction call ───────────────────────────────────────────────────

  @override
  Future<PredictionResult> getPredictionResult({
    required List<String> symptoms,
    required int age,
    required String gender,
    double? weight,
    double? height,
    int durationDays = 3,
    int severity = 2,
    List<String> existingConditions = const [],
    List<String> medications = const [],
    List<String> allergies = const [],
  }) async {
    final request = SymptomCheckApiRequest(
      symptoms: symptoms,
      age: age,
      gender: gender,
      weight: weight,
      height: height,
      duration: durationDays,
      severity: severity,
      existingDiseases: existingConditions,
      medications: medications,
      allergies: allergies,
    );

    final response = await remoteDataSource.predict(request);
    return _mapResponse(response);
  }

  // ── Response → domain entity mapping ──────────────────────────────────────

  PredictionResultModel _mapResponse(SymptomCheckApiResponse r) {
    final pred = r.prediction;
    final risk = r.riskAssessment;
    final rec = r.recommendations;
    final summary = r.inputSummary;

    final disease = Disease(
      id: _slugify(pred.primaryDisease),
      name: _titleCase(pred.primaryDisease),
      shortDescription: _buildShortDesc(pred.primaryDisease, risk.riskLevel),
      overview: _buildOverview(pred.primaryDisease, risk),
      symptoms: summary.symptoms,
      causes: const [],
      imageUrl: '',
    );

    final probabilities = <String, double>{};
    for (final d in pred.topDiseases) {
      if (d.disease.isNotEmpty) {
        probabilities[_titleCase(d.disease)] = d.confidence;
      }
    }
    probabilities.putIfAbsent(disease.name, () => pred.confidence);

    final recommendation = _mapRecommendation(rec, risk);

    return PredictionResultModel(
      id: 'prediction-${DateTime.now().millisecondsSinceEpoch}',
      disease: disease,
      confidence: pred.confidence,
      riskLevel: _normaliseRiskLevel(risk.riskLevel),
      probabilities: probabilities,
      recommendation: recommendation,
      createdAt: DateTime.now(),
      riskScore: risk.riskScore,
      riskFactors: risk.riskFactors,
      criticalSymptoms: risk.criticalSymptoms,
      isEmergency: risk.isEmergency,
      emergencyAlert: r.emergencyAlert,
      topDiseases: pred.topDiseases
          .map((d) => MapEntry(_titleCase(d.disease), d.confidence))
          .toList(),
      // Patient-profile summary
      bmi: summary.bmi,
      bmiCategory: summary.bmiCategory,
      durationCategory: summary.durationCategory,
      severityLabel: summary.severityLabel,
      existingConditions: summary.existingConditions,
      medications: summary.medications,
      allergies: summary.allergies,
      augmentationLog: summary.augmentationLog ?? const [],
      augmentedSymptomCount: summary.augmentedSymptomCount,
    );
  }

  Recommendation _mapRecommendation(
      ApiRecommendation rec, ApiRiskAssessment risk) {
    // Treatments from the actions list.
    final treatments = rec.actions.asMap().entries.map((e) {
      return Treatment(
        id: 't${e.key}',
        title: e.value,
        description: e.value,
        duration: 'As needed',
      );
    }).toList();

    // Medicines from care advice (simple mapping).
    final medicines = rec.careAdvice.asMap().entries.map((e) {
      return Medicine(
        id: 'm${e.key}',
        name: e.value,
        dosage: 'As directed',
        timing: 'As needed',
        note: '',
      );
    }).toList();

    // Preventions from risk factors.
    final preventions = risk.riskFactors.asMap().entries.map((e) {
      return Prevention(
        id: 'p${e.key}',
        title: 'Risk factor',
        description: e.value,
      );
    }).toList();

    final shouldVisit = rec.urgency != 'routine' || rec.emergencyContact;

    return Recommendation(
      treatments: treatments,
      medicines: medicines,
      preventions: preventions,
      nearbyHospitals: const <Hospital>[],
      shouldVisitDoctor: shouldVisit,
      doctorVisitReason: rec.primaryAction.isNotEmpty
          ? rec.primaryAction
          : 'Consult a healthcare professional for further evaluation.',
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _slugify(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  /// Map backend risk strings to the display strings the UI expects.
  String _normaliseRiskLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
      case 'moderate':
        return 'Medium';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      default:
        return 'Low';
    }
  }

  String _buildShortDesc(String disease, String riskLevel) {
    final r = _normaliseRiskLevel(riskLevel).toLowerCase();
    return 'AI assessment suggests $disease with $r risk based on your symptoms and profile.';
  }

  String _buildOverview(String disease, ApiRiskAssessment risk) {
    final factors = risk.riskFactors.isNotEmpty
        ? ' Contributing factors: ${risk.riskFactors.take(3).join(', ')}.'
        : '';
    return 'The AI model identified $disease as the most likely condition '
        'with a risk score of ${(risk.riskScore * 100).round()}%.$factors '
        'This is not a medical diagnosis — please consult a healthcare professional.';
  }

  // ── History ───────────────────────────────────────────────────────────────

  @override
  Future<List<PredictionResult>> getPredictionHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_history);
  }

  @override
  Future<void> savePrediction(PredictionResult result) async {
    _history.insert(0, result);
    // Keep at most 50 entries.
    if (_history.length > 50) _history.removeLast();
  }

  @override
  Future<Recommendation> getRecommendations(String diseaseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return switch (diseaseId) {
      'migraine' => DiseasePredictionDummyData.migraineRecommendation,
      'gastritis' => DiseasePredictionDummyData.gastritisRecommendation,
      _ => DiseasePredictionDummyData.fluRecommendation,
    };
  }
}
