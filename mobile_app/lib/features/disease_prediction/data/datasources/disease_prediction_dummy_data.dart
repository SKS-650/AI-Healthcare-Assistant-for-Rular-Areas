import '../models/disease_model.dart';
import '../models/hospital_model.dart';
import '../models/medicine_model.dart';
import '../models/prediction_result_model.dart';
import '../models/prevention_model.dart';
import '../models/recommendation_model.dart';
import '../models/treatment_model.dart';

class DiseasePredictionDummyData {
  static const DiseaseModel flu = DiseaseModel(
    id: 'flu',
    name: 'Seasonal Flu',
    shortDescription:
        'A viral respiratory illness that commonly causes fever, cough, and body aches.',
    overview:
        'Seasonal flu affects the nose, throat, and sometimes the lungs. Most people recover with rest, fluids, and symptom care, but severe or persistent symptoms need medical review.',
    symptoms: [
      'Fever',
      'Cough',
      'Body aches',
      'Fatigue',
      'Sore throat',
      'Runny nose',
    ],
    causes: [
      'Influenza virus',
      'Close contact with infected people',
      'Touching contaminated surfaces',
    ],
    imageUrl: 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144',
  );

  static const DiseaseModel migraine = DiseaseModel(
    id: 'migraine',
    name: 'Migraine',
    shortDescription:
        'A neurological condition that can cause intense headache, nausea, and light sensitivity.',
    overview:
        'Migraine attacks can last for hours or days and may be triggered by stress, sleep changes, dehydration, certain foods, or bright light.',
    symptoms: [
      'Headache',
      'Nausea',
      'Light sensitivity',
      'Dizziness',
      'Blurred vision',
    ],
    causes: [
      'Stress',
      'Sleep disruption',
      'Hormonal changes',
      'Dehydration',
      'Food triggers',
    ],
    imageUrl: 'https://images.unsplash.com/photo-1559757175-0eb30cd8c063',
  );

  static const DiseaseModel gastritis = DiseaseModel(
    id: 'gastritis',
    name: 'Gastritis',
    shortDescription:
        'Inflammation of the stomach lining that may cause upper abdominal pain and nausea.',
    overview:
        'Gastritis may be short term or long lasting. It can be related to infection, frequent pain medicine use, alcohol, spicy foods, or stress.',
    symptoms: [
      'Stomach pain',
      'Nausea',
      'Bloating',
      'Loss of appetite',
      'Indigestion',
    ],
    causes: [
      'H. pylori infection',
      'Frequent NSAID use',
      'Alcohol',
      'Stress',
      'Irritating foods',
    ],
    imageUrl: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118',
  );

  static const hospitals = [
    HospitalModel(
      id: 'h1',
      name: 'City General Hospital',
      address: 'Main Road, Kathmandu',
      distanceKm: 1.8,
      contactNumber: '+977-01-5550101',
      isOpen: true,
    ),
    HospitalModel(
      id: 'h2',
      name: 'Community Care Clinic',
      address: 'Health Street, Lalitpur',
      distanceKm: 3.4,
      contactNumber: '+977-01-5550202',
      isOpen: true,
    ),
  ];

  static const RecommendationModel fluRecommendation = RecommendationModel(
    treatments: [
      TreatmentModel(
        id: 't1',
        title: 'Rest and fluids',
        description:
            'Prioritize sleep, warm fluids, and light meals while symptoms are active.',
        duration: '3-5 days',
      ),
      TreatmentModel(
        id: 't2',
        title: 'Symptom monitoring',
        description:
            'Track fever, breathing difficulty, chest pain, or symptoms lasting longer than a week.',
        duration: 'Daily',
      ),
    ],
    medicines: [
      MedicineModel(
        id: 'm1',
        name: 'Paracetamol',
        dosage: '500 mg',
        timing: 'Every 6-8 hours if needed',
        note: 'Avoid exceeding the daily maximum dose.',
      ),
      MedicineModel(
        id: 'm2',
        name: 'Oral rehydration',
        dosage: 'As tolerated',
        timing: 'Throughout the day',
        note: 'Useful when fever or low appetite reduces fluid intake.',
      ),
    ],
    preventions: [
      PreventionModel(
        id: 'p1',
        title: 'Wash hands often',
        description: 'Clean hands before meals and after coughing or sneezing.',
      ),
      PreventionModel(
        id: 'p2',
        title: 'Use a mask',
        description: 'Masking reduces spread when coughing or feverish.',
      ),
    ],
    nearbyHospitals: hospitals,
    shouldVisitDoctor: true,
    doctorVisitReason:
        'Visit a clinician if fever is high, breathing is difficult, or symptoms worsen.',
  );

  static const RecommendationModel migraineRecommendation = RecommendationModel(
    treatments: [
      TreatmentModel(
        id: 't3',
        title: 'Quiet dark room',
        description:
            'Rest away from bright light, noise, and screens during the attack.',
        duration: 'Until symptoms improve',
      ),
      TreatmentModel(
        id: 't4',
        title: 'Hydration',
        description:
            'Drink water or electrolyte fluids, especially if nausea is present.',
        duration: 'Same day',
      ),
    ],
    medicines: [
      MedicineModel(
        id: 'm3',
        name: 'Ibuprofen',
        dosage: '200-400 mg',
        timing: 'At headache onset if appropriate',
        note: 'Avoid if you have ulcers, kidney disease, or allergy.',
      ),
    ],
    preventions: [
      PreventionModel(
        id: 'p3',
        title: 'Sleep routine',
        description: 'Keep consistent sleep and wake times.',
      ),
      PreventionModel(
        id: 'p4',
        title: 'Trigger journal',
        description: 'Record foods, stress, sleep, and weather around attacks.',
      ),
    ],
    nearbyHospitals: hospitals,
    shouldVisitDoctor: true,
    doctorVisitReason:
        'Seek care for sudden severe headache, weakness, confusion, fever, or vision loss.',
  );

  static const RecommendationModel
  gastritisRecommendation = RecommendationModel(
    treatments: [
      TreatmentModel(
        id: 't5',
        title: 'Gentle diet',
        description:
            'Choose bland meals and avoid alcohol, spicy food, and heavy fried foods.',
        duration: 'Several days',
      ),
      TreatmentModel(
        id: 't6',
        title: 'Small meals',
        description:
            'Eat smaller portions more frequently to reduce stomach irritation.',
        duration: '1 week',
      ),
    ],
    medicines: [
      MedicineModel(
        id: 'm4',
        name: 'Antacid',
        dosage: 'As directed',
        timing: 'After meals if needed',
        note: 'Ask a clinician if symptoms are recurrent.',
      ),
    ],
    preventions: [
      PreventionModel(
        id: 'p5',
        title: 'Avoid unnecessary NSAIDs',
        description:
            'Frequent pain medicine use can irritate the stomach lining.',
      ),
      PreventionModel(
        id: 'p6',
        title: 'Limit irritants',
        description: 'Reduce alcohol, smoking, and highly spicy meals.',
      ),
    ],
    nearbyHospitals: hospitals,
    shouldVisitDoctor: true,
    doctorVisitReason:
        'Urgent care is needed for vomiting blood, black stool, severe pain, or dehydration.',
  );

  static List<PredictionResultModel> initialHistory() {
    return [
      buildResult(flu, fluRecommendation, 0.82, 'Moderate'),
      buildResult(migraine, migraineRecommendation, 0.76, 'Low'),
    ];
  }

  static PredictionResultModel buildResult(
    DiseaseModel disease,
    RecommendationModel recommendation,
    double confidence,
    String riskLevel,
  ) {
    return PredictionResultModel(
      id: 'prediction-${DateTime.now().millisecondsSinceEpoch}',
      disease: disease,
      confidence: confidence,
      riskLevel: riskLevel,
      probabilities: {
        disease.name: confidence,
        'Seasonal Flu': disease.id == flu.id ? confidence : 0.32,
        'Migraine': disease.id == migraine.id ? confidence : 0.28,
        'Gastritis': disease.id == gastritis.id ? confidence : 0.21,
      },
      recommendation: recommendation,
      createdAt: DateTime.now(),
    );
  }

  static ({
    DiseaseModel disease,
    RecommendationModel recommendation,
    double confidence,
    String riskLevel,
  })
  matchSymptoms(List<String> symptoms) {
    final normalized = symptoms
        .map((symptom) => symptom.toLowerCase())
        .join(' ');

    if (normalized.contains('headache') ||
        normalized.contains('light') ||
        normalized.contains('dizzy')) {
      return (
        disease: migraine,
        recommendation: migraineRecommendation,
        confidence: 0.78,
        riskLevel: 'Low',
      );
    }

    if (normalized.contains('stomach') ||
        normalized.contains('bloat') ||
        normalized.contains('indigestion') ||
        normalized.contains('nausea')) {
      return (
        disease: gastritis,
        recommendation: gastritisRecommendation,
        confidence: 0.73,
        riskLevel: 'Moderate',
      );
    }

    return (
      disease: flu,
      recommendation: fluRecommendation,
      confidence: 0.84,
      riskLevel: 'Moderate',
    );
  }
}
