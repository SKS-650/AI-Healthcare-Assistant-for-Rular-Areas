/// On-device symptom assessment engine.
///
/// When the backend Random Forest model is unreachable this engine uses:
///   • The hard-coded disease knowledge base (disease_knowledge.dart)
///   • A simple symptom-to-disease scoring function
///   • Risk assessment rules that mirror the backend logic
///   • Recommendation generation per risk level
///
/// The result shape exactly matches [OfflineSymptomResult] so the UI
/// can render it with zero changes.
library;

import 'package:uuid/uuid.dart';

import '../../domain/entities/offline_symptom_result.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Knowledge base — disease → symptoms mapping
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, List<String>> _diseaseSymptoms = {
  'Common Cold': [
    'runny nose', 'sneezing', 'sore throat', 'cough', 'congestion',
    'mild fever', 'fatigue', 'headache',
  ],
  'Influenza': [
    'fever', 'chills', 'body aches', 'headache', 'fatigue', 'cough',
    'sore throat', 'runny nose', 'weakness',
  ],
  'COVID-19': [
    'fever', 'cough', 'shortness of breath', 'fatigue', 'loss of taste',
    'loss of smell', 'headache', 'body aches', 'sore throat',
  ],
  'Pneumonia': [
    'fever', 'cough', 'shortness of breath', 'chest pain', 'fatigue',
    'chills', 'difficulty breathing',
  ],
  'Malaria': [
    'fever', 'chills', 'sweating', 'headache', 'nausea', 'vomiting',
    'muscle pain', 'fatigue',
  ],
  'Typhoid': [
    'fever', 'headache', 'abdominal pain', 'weakness', 'diarrhea',
    'constipation', 'skin rash', 'loss of appetite',
  ],
  'Dengue': [
    'fever', 'severe headache', 'eye pain', 'joint pain', 'muscle pain',
    'rash', 'mild bleeding', 'fatigue',
  ],
  'Tuberculosis': [
    'persistent cough', 'coughing blood', 'chest pain', 'fatigue',
    'weight loss', 'night sweats', 'fever', 'loss of appetite',
  ],
  'Hypertension': [
    'headache', 'dizziness', 'chest pain', 'blurred vision',
    'shortness of breath', 'nosebleed',
  ],
  'Diabetes': [
    'frequent urination', 'excessive thirst', 'fatigue', 'blurred vision',
    'slow healing', 'weight loss', 'increased hunger',
  ],
  'Asthma': [
    'wheezing', 'shortness of breath', 'chest tightness', 'cough',
    'difficulty breathing', 'night cough',
  ],
  'Gastroenteritis': [
    'diarrhea', 'nausea', 'vomiting', 'abdominal pain', 'stomach cramps',
    'fever', 'dehydration',
  ],
  'Urinary Tract Infection': [
    'burning urination', 'frequent urination', 'cloudy urine', 'pelvic pain',
    'lower abdominal pain', 'strong urine odor', 'fever',
  ],
  'Migraine': [
    'severe headache', 'nausea', 'vomiting', 'light sensitivity',
    'sound sensitivity', 'visual aura', 'throbbing pain',
  ],
  'Anemia': [
    'fatigue', 'weakness', 'pale skin', 'shortness of breath', 'dizziness',
    'cold hands', 'headache', 'chest pain',
  ],
  'Chickenpox': [
    'itchy rash', 'blister', 'fever', 'fatigue', 'headache', 'loss of appetite',
    'fluid filled blisters',
  ],
  'Measles': [
    'fever', 'rash', 'cough', 'runny nose', 'red eyes', 'koplik spots',
    'sensitivity to light',
  ],
  'Hepatitis': [
    'jaundice', 'fatigue', 'abdominal pain', 'nausea', 'vomiting',
    'dark urine', 'loss of appetite', 'fever',
  ],
  'Appendicitis': [
    'abdominal pain', 'nausea', 'vomiting', 'fever', 'loss of appetite',
    'right lower pain', 'rebound tenderness',
  ],
  'Heart Attack': [
    'chest pain', 'shortness of breath', 'sweating', 'nausea', 'arm pain',
    'jaw pain', 'dizziness', 'irregular heartbeat',
  ],
};

// ── Diet recommendations per disease ─────────────────────────────────────────
const Map<String, List<String>> _diseaseDiet = {
  'Common Cold':   ['Warm soups', 'Honey-lemon tea', 'Citrus fruits', 'Ginger tea'],
  'Influenza':     ['Clear broths', 'Herbal teas', 'Fruits rich in Vitamin C', 'Plenty of fluids'],
  'COVID-19':      ['Zinc-rich foods', 'Vitamin D sources', 'Warm fluids', 'High-protein foods'],
  'Malaria':       ['Easy-to-digest foods', 'Coconut water', 'Porridge', 'Fruits'],
  'Typhoid':       ['Soft bland diet', 'Boiled vegetables', 'Rice porridge', 'Bananas'],
  'Dengue':        ['Papaya leaf juice', 'Coconut water', 'Pomegranate juice', 'Green leafy vegetables'],
  'Tuberculosis':  ['High-calorie foods', 'Protein-rich diet', 'Vitamins A, C, E', 'Dairy products'],
  'Hypertension':  ['Low sodium foods', 'DASH diet', 'Leafy greens', 'Berries', 'Bananas'],
  'Diabetes':      ['Low glycaemic index foods', 'Whole grains', 'Non-starchy vegetables', 'Lean proteins'],
  'Asthma':        ['Anti-inflammatory foods', 'Omega-3 rich fish', 'Apples', 'Broccoli'],
  'Gastroenteritis': ['BRAT diet (bananas, rice, applesauce, toast)', 'Clear fluids', 'Electrolytes'],
  'Anemia':        ['Iron-rich foods (spinach, lentils)', 'Vitamin C', 'Fortified cereals', 'Red meat'],
  'Heart Attack':  ['Heart-healthy diet', 'Omega-3 fatty acids', 'Low saturated fat', 'Fruits and vegetables'],
};

// ── Precautions per disease ───────────────────────────────────────────────────
const Map<String, List<String>> _diseasePrecautions = {
  'Common Cold':   ['Rest well', 'Stay warm', 'Wash hands frequently', 'Avoid crowded places'],
  'Influenza':     ['Get vaccinated annually', 'Avoid sick contacts', 'Rest at home', 'Cover coughs'],
  'COVID-19':      ['Wear mask', 'Maintain social distancing', 'Ventilate spaces', 'Monitor oxygen levels'],
  'Malaria':       ['Use mosquito nets', 'Apply insect repellent', 'Wear long sleeves', 'Take prophylaxis'],
  'Typhoid':       ['Drink safe water', 'Eat properly cooked food', 'Wash hands', 'Typhoid vaccine'],
  'Dengue':        ['Eliminate stagnant water', 'Use mosquito repellent', 'Wear protective clothing'],
  'Tuberculosis':  ['Cover mouth when coughing', 'Complete full TB treatment', 'Ventilate rooms', 'Regular check-ups'],
  'Hypertension':  ['Monitor BP regularly', 'Reduce stress', 'Limit alcohol', 'Stop smoking', 'Exercise daily'],
  'Diabetes':      ['Monitor blood sugar daily', 'Take medication on time', 'Regular foot care', 'Eye check-ups'],
  'Asthma':        ['Avoid triggers', 'Keep inhaler available', 'Avoid cold air', 'Regular lung check-up'],
  'Heart Attack':  ['Call emergency immediately', 'Do NOT drive yourself', 'Chew aspirin if available', 'Rest'],
  'Appendicitis':  ['Do NOT apply heat to abdomen', 'Do NOT take pain killers without consulting doctor', 'Seek emergency care'],
};

// ── Workout recommendations per disease ──────────────────────────────────────
const Map<String, List<String>> _diseaseWorkouts = {
  'Common Cold':      ['Light walking', 'Gentle stretching', 'Rest and recovery'],
  'Hypertension':     ['Brisk walking 30 min', 'Swimming', 'Cycling', 'Yoga'],
  'Diabetes':         ['Walking after meals', 'Resistance training', 'Yoga', 'Cycling'],
  'Asthma':           ['Swimming (humidity helps)', 'Walking', 'Yoga breathing exercises'],
  'Anemia':           ['Light walking', 'Gentle yoga', 'Avoid intense exercise until levels improve'],
  'Heart Attack':     ['No exercise until medically cleared', 'Cardiac rehab when approved'],
  'Tuberculosis':     ['Rest during acute phase', 'Light walking in fresh air after stabilisation'],
  'Gastroenteritis':  ['Complete rest until symptoms resolve', 'Light walking once recovered'],
};

// ── Emergency symptoms ────────────────────────────────────────────────────────
const List<String> _emergencySymptoms = [
  'chest pain', 'shortness of breath', 'difficulty breathing',
  'coughing blood', 'severe headache', 'loss of consciousness',
  'seizure', 'stroke', 'arm pain', 'jaw pain', 'irregular heartbeat',
  'severe abdominal pain', 'rebound tenderness',
];

// ─────────────────────────────────────────────────────────────────────────────
// Engine
// ─────────────────────────────────────────────────────────────────────────────

class OfflineSymptomEngine {
  const OfflineSymptomEngine();

  static const _uuid = Uuid();

  /// Run a fully offline prediction given a list of symptom strings.
  OfflineSymptomResult predict({
    required List<String> symptoms,
    int age = 30,
    String gender = 'unknown',
  }) {
    final normalised = symptoms.map(_normalise).toList();

    // Score every disease
    final scores = <String, double>{};
    _diseaseSymptoms.forEach((disease, diseaseSymptoms) {
      int matches = 0;
      for (final s in normalised) {
        if (diseaseSymptoms.any((ds) => ds.contains(s) || s.contains(ds))) {
          matches++;
        }
      }
      if (matches > 0) {
        scores[disease] =
            matches / diseaseSymptoms.length.toDouble();
      }
    });

    if (scores.isEmpty) {
      return _unknownResult(symptoms, age, gender);
    }

    // Sort by score descending
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final primary      = sorted.first.key;
    final confidence   = (sorted.first.value).clamp(0.0, 1.0);
    final topDiseases  = sorted.take(5).map((e) => DiseaseConfidencePair(
          disease:    e.key,
          confidence: e.value.clamp(0.0, 1.0),
        )).toList();

    // Risk assessment
    final criticalSymptoms = normalised
        .where((s) => _emergencySymptoms.any((e) => s.contains(e) || e.contains(s)))
        .toList();
    final isEmergency = criticalSymptoms.isNotEmpty || primary == 'Heart Attack' || primary == 'Appendicitis';

    final riskLevel = _calculateRisk(
      confidence:       confidence,
      isEmergency:      isEmergency,
      symptomCount:     symptoms.length,
      age:              age,
    );

    // Recommendations
    final recs     = _buildRecommendations(riskLevel, primary);
    final diet     = _diseaseDiet[primary] ?? _defaultDiet;
    final precautions = _diseasePrecautions[primary] ?? _defaultPrecautions;
    final workouts = _diseaseWorkouts[primary] ?? _defaultWorkout;

    return OfflineSymptomResult(
      id:                  _uuid.v4(),
      symptoms:            symptoms,
      primaryDisease:      primary,
      confidence:          confidence,
      riskLevel:           riskLevel,
      topDiseases:         topDiseases,
      recommendations:     recs,
      dietRecommendations: diet,
      precautions:         precautions,
      workouts:            workouts,
      isEmergency:         isEmergency,
      criticalSymptoms:    criticalSymptoms,
      createdAt:           DateTime.now(),
      age:                 age,
      gender:              gender,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _normalise(String s) => s.toLowerCase().trim();

  String _calculateRisk({
    required double confidence,
    required bool isEmergency,
    required int symptomCount,
    required int age,
  }) {
    if (isEmergency) return 'critical';
    if (age >= 65 && confidence >= 0.5) return 'high';
    if (confidence >= 0.7) return 'high';
    if (confidence >= 0.45 || symptomCount >= 5) return 'medium';
    return 'low';
  }

  List<String> _buildRecommendations(String riskLevel, String disease) {
    switch (riskLevel) {
      case 'critical':
        return [
          '🚨 EMERGENCY — Call 108 / 112 immediately',
          'Do not wait — go to the nearest emergency room',
          'If available, take aspirin (for cardiac symptoms)',
          'Do not eat or drink anything until seen by a doctor',
        ];
      case 'high':
        return [
          'Visit a doctor within 24 hours',
          'Monitor symptoms closely',
          'Rest and avoid physical strain',
          'Stay hydrated',
          'Seek urgent care if symptoms worsen',
        ];
      case 'medium':
        return [
          'Schedule a doctor appointment within 2–3 days',
          'Rest at home',
          'Take OTC medication as appropriate',
          'Monitor temperature and symptoms',
          'Call doctor immediately if symptoms worsen',
        ];
      default:
        return [
          'Rest and take care of yourself',
          'Stay hydrated and eat well',
          'Use OTC remedies as needed',
          'See a doctor if symptoms persist beyond 3 days',
        ];
    }
  }

  OfflineSymptomResult _unknownResult(
      List<String> symptoms, int age, String gender) {
    return OfflineSymptomResult(
      id:                  _uuid.v4(),
      symptoms:            symptoms,
      primaryDisease:      'General Illness (Unspecified)',
      confidence:          0.3,
      riskLevel:           'low',
      topDiseases:         [],
      recommendations:     [
        'Consult a doctor for proper diagnosis',
        'Rest and stay hydrated',
        'Monitor symptoms for 24–48 hours',
      ],
      dietRecommendations: _defaultDiet,
      precautions:         _defaultPrecautions,
      workouts:            _defaultWorkout,
      isEmergency:         false,
      criticalSymptoms:    [],
      createdAt:           DateTime.now(),
      age:                 age,
      gender:              gender,
    );
  }

  static const _defaultDiet = [
    'Drink plenty of water',
    'Eat balanced meals',
    'Include fruits and vegetables',
  ];

  static const _defaultPrecautions = [
    'Rest well',
    'Wash hands frequently',
    'Avoid self-medication without advice',
  ];

  static const _defaultWorkout = [
    'Light walking only',
    'Rest until symptoms improve',
  ];
}
