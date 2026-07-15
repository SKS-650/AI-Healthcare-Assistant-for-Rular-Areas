import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../../constants/api_constants.dart';
import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../domain/entities/emergency_assessment.dart';
import '../models/emergency_assessment_model.dart';

/// Handles all HTTP calls to the backend Emergency API.
/// Falls back gracefully on network errors so the UI never crashes.
class EmergencyRemoteDatasource {
  final AuthenticationRepositoryImpl _authRepo;

  EmergencyRemoteDatasource(this._authRepo);

  // ── Assessment ────────────────────────────────────────────────────────────

  /// POST /api/v1/emergency/assessment
  Future<EmergencyAssessmentModel> runAssessment(AssessmentInput input) async {
    final response = await _authRepo.authenticatedRequest(
      (headers) => http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConstants.emergencyAssessmentPath}',
            ),
            headers: headers,
            body: jsonEncode(input.toJson()),
          )
          .timeout(const Duration(seconds: 30)),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return EmergencyAssessmentModel.fromJson(data);
    }

    throw Exception(
      'Assessment request failed with status ${response.statusCode}: '
      '${response.body}',
    );
  }

  /// GET /api/v1/emergency/history
  Future<List<EmergencyAssessmentModel>> getAssessmentHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConstants.emergencyHistoryPath}'
      '?limit=$limit&offset=$offset',
    );

    final response = await _authRepo.authenticatedRequest(
      (headers) => http.get(uri, headers: headers)
          .timeout(const Duration(seconds: 20)),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['assessments'] as List? ?? [];
      return items
          .map((e) => EmergencyAssessmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Auth users only — if 401 return empty list
    return [];
  }

  /// GET /api/v1/emergency/assessment/{id}
  Future<EmergencyAssessmentModel> getAssessmentById(String id) async {
    final response = await _authRepo.authenticatedRequest(
      (headers) => http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConstants.emergencyAssessmentById(id)}',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20)),
    );

    if (response.statusCode == 200) {
      return EmergencyAssessmentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception('Assessment $id not found (${response.statusCode})');
  }

  // ── SOS ───────────────────────────────────────────────────────────────────

  /// POST /api/v1/emergency/sos
  Future<void> triggerSos({
    required String emergencyType,
    double? locationLat,
    double? locationLng,
    String? locationText,
    String? assessmentId,
  }) async {
    final body = <String, dynamic>{
      'emergency_type': emergencyType,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (locationText != null) 'location_text': locationText,
      if (assessmentId != null) 'assessment_id': assessmentId,
    };

    await _authRepo.authenticatedRequest(
      (headers) => http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConstants.emergencySosPath}',
            ),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20)),
    );
    // Fire-and-forget — SOS success is handled by the notifier
  }

  // ── Contacts CRUD ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createContact({
    required String name,
    required String phoneNumber,
    required String relation,
    bool isPrimary = false,
  }) async {
    final response = await _authRepo.authenticatedRequest(
      (headers) => http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConstants.emergencyContactsPath}',
            ),
            headers: headers,
            body: jsonEncode({
              'name': name,
              'phone_number': phoneNumber,
              'relation': relation,
              'is_primary': isPrimary,
            }),
          )
          .timeout(const Duration(seconds: 20)),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Create contact failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateContact({
    required String contactId,
    String? name,
    String? phoneNumber,
    String? relation,
    bool? isPrimary,
  }) async {
    final response = await _authRepo.authenticatedRequest(
      (headers) => http
          .put(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConstants.emergencyContactById(contactId)}',
            ),
            headers: headers,
            body: jsonEncode({
              if (name != null) 'name': name,
              if (phoneNumber != null) 'phone_number': phoneNumber,
              if (relation != null) 'relation': relation,
              if (isPrimary != null) 'is_primary': isPrimary,
            }),
          )
          .timeout(const Duration(seconds: 20)),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Update contact failed: ${response.statusCode}');
  }

  Future<void> deleteContact(String contactId) async {
    await _authRepo.authenticatedRequest(
      (headers) => http
          .delete(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConstants.emergencyContactById(contactId)}',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20)),
    );
  }
}
