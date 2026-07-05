import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/symptom_check_request.dart';
import '../models/symptom_check_response.dart';

class SymptomCheckerService {
  final String baseUrl;
  final String? authToken;

  SymptomCheckerService({
    required this.baseUrl,
    this.authToken,
  });

  /// Get HTTP headers with authentication
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  /// Check symptoms and get disease predictions
  Future<SymptomCheckResponse> checkSymptoms(
    SymptomCheckRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/symptom-checker/predict'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SymptomCheckResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 503) {
        throw Exception('Symptom checker service is currently unavailable.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to check symptoms');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get list of available symptoms
  Future<List<String>> getAvailableSymptoms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/symptom-checker/symptoms'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['symptoms'] ?? []);
      } else {
        throw Exception('Failed to load symptoms');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get list of diseases model can predict
  Future<List<String>> getAvailableDiseases() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/symptom-checker/diseases'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['diseases'] ?? []);
      } else {
        throw Exception('Failed to load diseases');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Check service health
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/symptom-checker/health'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Service health check failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
