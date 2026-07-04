import '../constants/api_constants.dart';

class ApiConfig {
  const ApiConfig._();

  static const baseUrl = 'http://localhost:8000';
  static const symptomsUrl = '$baseUrl${ApiConstants.symptomsPath}';
  static const predictionUrl = '$baseUrl${ApiConstants.predictionPath}';
}
