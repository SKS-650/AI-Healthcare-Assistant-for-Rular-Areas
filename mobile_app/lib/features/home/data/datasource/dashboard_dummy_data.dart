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

  static const List<HospitalModel> nearbyHospitals = [
    HospitalModel(
        id: '1',
        name: 'City General Hospital',
        distance: 1.2,
        address: '123 Health Ave, Downtown'),
    HospitalModel(
        id: '2',
        name: 'St. Mary Healthcare Center',
        distance: 3.5,
        address: '789 Care Rd, Suburbia'),
  ];

  static const List<String> healthTips = [
    'Drink at least 8 glasses of water today to stay fully hydrated.',
    'A 10-minute walk after lunch can drastically improve your digestion speeds.',
    'Limit screen time 1 hour before bed to optimize your deep sleep phases.',
  ];

  static const List<ArticleModel> latestArticles = [
    ArticleModel(
        id: '1',
        title: 'Understanding Dietary Riboflavin & Micronutrients',
        category: 'Nutrition',
        imageUrl: 'https://via.placeholder.com/150',
        readTime: '5 min read'),
    ArticleModel(
        id: '2',
        title: 'Mental Resilience Exercises During Work Hours',
        category: 'Mental Health',
        imageUrl: 'https://via.placeholder.com/150',
        readTime: '4 min read'),
  ];
}
