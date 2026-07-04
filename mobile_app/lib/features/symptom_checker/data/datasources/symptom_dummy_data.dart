import '../models/symptom_model.dart';
import '../models/dummy_result_model.dart';

class SymptomDummyData {
  static const List<SymptomModel> availableSymptoms = [
    SymptomModel(id: 's1', name: 'Fever', category: 'General', description: 'Elevated body temperature and feeling warm.'),
    SymptomModel(id: 's2', name: 'Dry Cough', category: 'Respiratory', description: 'Persistent dry cough without mucus.'),
    SymptomModel(id: 's3', name: 'Shortness of Breath', category: 'Respiratory', description: 'Difficulty breathing or feeling breathless.'),
    SymptomModel(id: 's4', name: 'Headache', category: 'Neurological', description: 'Pain or pressure in the head.'),
    SymptomModel(id: 's5', name: 'Fatigue', category: 'General', description: 'Unusual tiredness or low energy.'),
    SymptomModel(id: 's6', name: 'Sore Throat', category: 'Respiratory', description: 'Pain or irritation when swallowing.'),
    SymptomModel(id: 's7', name: 'Chest Pain', category: 'Cardiovascular', description: 'Discomfort or pain in the chest area.'),
    SymptomModel(id: 's8', name: 'Nausea', category: 'Gastrointestinal', description: 'Feeling like you might vomit.'),
    SymptomModel(id: 's9', name: 'Dizziness', category: 'Neurological', description: 'Lightheadedness or feeling faint.'),
    SymptomModel(id: 's10', name: 'Muscle Aches', category: 'General', description: 'Generalized body soreness or aches.'),
  ];

  static final DummyResultModel mockResultHighRisk = DummyResultModel(
    conditionName: 'Possible Viral Respiratory Infection',
    confidenceScore: 0.88,
    riskLevel: 'High',
    description: 'Based on your symptoms of high fever, dry cough, and shortness of breath, there is a strong correlation with lower respiratory tract infections.',
    recommendations: [
      'Consult a primary care physician immediately.',
      'Monitor oxygen saturation levels if a oximeter is available.',
      'Isolate from family members to prevent potential virus spread.'
    ],
  );

  static final DummyResultModel mockResultMildRisk = DummyResultModel(
    conditionName: 'Mild Common Cold / Tension Headache',
    confidenceScore: 0.65,
    riskLevel: 'Low',
    description: 'Your symptoms suggest a mild upper respiratory viral track infection or fatigue-induced tension headache.',
    recommendations: [
      'Ensure adequate rest and hydration (2-3 liters of water daily).',
      'Over-the-counter pain relief can be considered for headaches if appropriate.',
      'Track symptoms over the next 48 hours.'
    ],
  );
}