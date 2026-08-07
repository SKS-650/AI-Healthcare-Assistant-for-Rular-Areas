// lib/features/home/data/datasource/dashboard_dummy_data.dart
import '../models/weather_model.dart';
import '../models/health_score_model.dart';
import '../../domain/entities/quick_action.dart';
import '../models/prediction_model.dart';
import '../models/hospital_model.dart';
import '../models/article_model.dart';

class DashboardDummyData {
  static const weather = WeatherModel(
    temperature: 24.5,
    condition: 'Partly Cloudy',
    humidity: 62,
    aqi: 42,
    location: 'New York, USA',
  );

  static const healthScore = HealthScoreModel(
    score: 85,
    status: 'Excellent',
    description:
        'Your health parameters look steady today. Keep up the good work!',
  );

  static const List<QuickAction> quickActions = [
    QuickAction(
        id: 'symptom',
        title: 'Symptom Checker',
        iconPath: 'assets/icons/symptom.svg',
        routeName: '/symptom-checker'),
    QuickAction(
        id: 'chatbot',
        title: 'AI Chatbot',
        iconPath: 'assets/icons/chatbot.svg',
        routeName: '/chatbot'),
    QuickAction(
        id: 'emergency',
        title: 'Emergency',
        iconPath: 'assets/icons/emergency.svg',
        routeName: '/emergency'),
    QuickAction(
        id: 'records',
        title: 'Health Records',
        iconPath: 'assets/icons/records.svg',
        routeName: '/records'),
    QuickAction(
        id: 'education',
        title: 'Education',
        iconPath: 'assets/icons/education.svg',
        routeName: '/education'),
    QuickAction(
        id: 'profile',
        title: 'Profile',
        iconPath: 'assets/icons/profile.svg',
        routeName: '/profile'),
  ];

  static final List<PredictionModel> recentPredictions = [
    PredictionModel(
        id: '1',
        diseaseName: 'Common Cold Risk',
        confidence: 0.88,
        date: DateTime.now().subtract(const Duration(days: 2))),
    PredictionModel(
        id: '2',
        diseaseName: 'Seasonal Allergy',
        confidence: 0.74,
        date: DateTime.now().subtract(const Duration(days: 5))),
  ];

  static const List<String> healthTips = [
    'Drink at least 8 glasses of water today to keep your body fully hydrated and energised.',
    'A brisk 10-minute walk after lunch boosts metabolism and improves digestion significantly.',
    'Limit screen time to 1 hour before bed — blue light disrupts melatonin and deep sleep.',
    'Eat a rainbow of colourful vegetables daily to maximise your intake of antioxidants.',
    'Practice 5 minutes of deep belly breathing every morning to lower cortisol levels.',
    'Replace refined sugar snacks with fruits, nuts, or yoghurt to stabilise blood sugar.',
    'Wash your hands thoroughly for 20 seconds before every meal to prevent infections.',
    'Stand up and stretch for 2 minutes every hour if you work at a desk all day.',
    'Aim for 7–9 hours of uninterrupted sleep — it rebuilds tissue and sharpens memory.',
    'Include probiotic foods like yoghurt or kefir weekly to support your gut microbiome.',
    'Reduce sodium intake by cooking at home and reading food labels carefully.',
    'Sunlight exposure for 15 minutes daily helps your body produce essential Vitamin D.',
    'Stay socially connected — strong relationships reduce stress and improve heart health.',
    'Never skip breakfast — a protein-rich morning meal keeps cravings away until noon.',
    'Add a handful of nuts to your diet daily for heart-healthy unsaturated fats and fibre.',
    'Track your steps — 8,000 steps per day is proven to reduce all-cause mortality risk.',
    'Cold water splashed on your face in the morning boosts alertness better than coffee.',
    'Chew each bite of food 20–30 times — it reduces overeating by giving satiety signals time.',
  ];

  static const List<HospitalModel> nearbyHospitals = [
    HospitalModel(
      id: 'h1',
      name: 'City General Hospital',
      address: '12 Main Street, Downtown',
      distance: 1.2,
      phone: '108',
      emergencyAvailable: true,
    ),
    HospitalModel(
      id: 'h2',
      name: 'Apollo Medical Centre',
      address: '45 Park Avenue, Midtown',
      distance: 2.7,
      phone: '1860-500-1066',
      emergencyAvailable: true,
    ),
    HospitalModel(
      id: 'h3',
      name: 'Community Health Clinic',
      address: '78 Green Road, Eastside',
      distance: 3.5,
      phone: '011-2345-6789',
      emergencyAvailable: false,
    ),
  ];

  static const List<ArticleModel> latestArticles = [
    ArticleModel(
        id: '1',
        title: 'Understanding Dietary Riboflavin & Micronutrients',
        category: 'Nutrition',
        imageUrl: '',
        readTime: '5 min read'),
    ArticleModel(
        id: '2',
        title: 'Mental Resilience Exercises During Work Hours',
        category: 'Mental Health',
        imageUrl: '',
        readTime: '4 min read'),
    ArticleModel(
        id: '3',
        title: '10 Best Full-Body Workouts You Can Do At Home',
        category: 'Fitness',
        imageUrl: '',
        readTime: '6 min read'),
    ArticleModel(
        id: '4',
        title: 'How Sleep Quality Impacts Your Immune System',
        category: 'Lifestyle',
        imageUrl: '',
        readTime: '5 min read'),
    ArticleModel(
        id: '5',
        title: 'Signs of Vitamin D Deficiency You Must Not Ignore',
        category: 'Disease',
        imageUrl: '',
        readTime: '4 min read'),
    ArticleModel(
        id: '6',
        title: 'Complete Guide to Child Vaccination Schedules 2025',
        category: 'Vaccination',
        imageUrl: '',
        readTime: '7 min read'),
    ArticleModel(
        id: '7',
        title: 'First Aid Essentials Every Family Should Know',
        category: 'First Aid',
        imageUrl: '',
        readTime: '5 min read'),
    ArticleModel(
        id: '8',
        title: 'Gut Health: Foods That Balance Your Microbiome',
        category: 'Nutrition',
        imageUrl: '',
        readTime: '6 min read'),
    ArticleModel(
        id: '9',
        title: 'Managing Anxiety: Breathing Techniques That Work',
        category: 'Mental Health',
        imageUrl: '',
        readTime: '4 min read'),
    ArticleModel(
        id: '10',
        title: 'Diabetes Prevention Through Daily Lifestyle Habits',
        category: 'Disease',
        imageUrl: '',
        readTime: '6 min read'),
    ArticleModel(
        id: '11',
        title: 'Prenatal Nutrition Guide for Expecting Mothers',
        category: 'Maternal',
        imageUrl: '',
        readTime: '8 min read'),
    ArticleModel(
        id: '12',
        title: 'Hand Hygiene: Why It Remains the #1 Infection Shield',
        category: 'Hygiene',
        imageUrl: '',
        readTime: '3 min read'),
    ArticleModel(
        id: '13',
        title: 'Strength Training Over 40: A Safer Approach',
        category: 'Fitness',
        imageUrl: '',
        readTime: '5 min read'),
    ArticleModel(
        id: '14',
        title: 'The Science of Hydration & Cognitive Performance',
        category: 'Lifestyle',
        imageUrl: '',
        readTime: '4 min read'),
    ArticleModel(
        id: '15',
        title: 'Heart-Healthy Superfoods to Add to Every Meal',
        category: 'Nutrition',
        imageUrl: '',
        readTime: '5 min read'),
  ];
}
