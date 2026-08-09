/// Remote data source for the Medical Records (PHR) module.
///
/// All methods call the FastAPI backend at /api/v1/health-records/*.
/// Uses [SimpleApiClient] (http package wrapper with Bearer token injection
/// and 401→refresh retry) — the same pattern used by the emergency module.
///
/// Throws [Exception] on non-2xx responses so the repository can catch and
/// present user-friendly messages.
library;

import 'dart:convert';

import '../../../../core/network/dio_client.dart';
import '../models/health_summary_model.dart';
import '../models/medical_history_model.dart';
import '../models/medical_image_model.dart';
import '../models/medical_profile_model.dart';
import '../models/prescription_model.dart';
import '../models/timeline_event_model.dart';

/// Base path for all health records endpoints.
/// SimpleApiClient.get(path) prepends ApiConfig.apiBaseUrl which already
/// includes /api/v1, so this path must NOT repeat the prefix.
const _kBase = '/health-records';

class HealthRecordsRemoteDataSource {
  HealthRecordsRemoteDataSource._();
  static final HealthRecordsRemoteDataSource instance =
      HealthRecordsRemoteDataSource._();

  final _client = SimpleApiClient.instance;

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _decode(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Unexpected response format');
  }

  List<dynamic> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) return decoded;
    throw Exception('Unexpected response format (expected list)');
  }

  void _checkStatus(int status, String body) {
    if (status >= 200 && status < 300) return;
    // 204 No Content is a success — body will be empty so skip parsing.
    if (status == 204) return;
    String message = 'Request failed ($status)';
    try {
      if (body.isNotEmpty) {
        final d = jsonDecode(body);
        if (d is Map && d['detail'] != null) {
          message = d['detail'].toString();
        }
      }
    } catch (_) {}
    throw Exception(message);
  }

  // ── Delete helper: 204 responses have no body so skip json check ──────────
  void _checkDelete(int status) {
    if (status == 204 || (status >= 200 && status < 300)) return;
    throw Exception('Delete failed ($status)');
  }

  // ─── Dashboard Summary ────────────────────────────────────────────────────

  Future<HealthSummaryModel> getSummary() async {
    final resp = await _client.get('$_kBase/summary');
    _checkStatus(resp.statusCode, resp.body);
    return HealthSummaryModel.fromJson(_decode(resp.body));
  }

  // ─── Medical Profile ──────────────────────────────────────────────────────

  Future<MedicalProfileModel> getMedicalProfile() async {
    final resp = await _client.get('$_kBase/profile');
    _checkStatus(resp.statusCode, resp.body);
    return MedicalProfileModel.fromJson(_decode(resp.body));
  }

  Future<MedicalProfileModel> upsertMedicalProfile(
      Map<String, dynamic> json) async {
    final resp = await _client.put(
      '$_kBase/profile',
      body: jsonEncode(json),
    );
    _checkStatus(resp.statusCode, resp.body);
    return MedicalProfileModel.fromJson(_decode(resp.body));
  }

  // ─── Medical History ──────────────────────────────────────────────────────

  Future<List<MedicalHistoryModel>> getMedicalHistory({
    String? category,
    int limit = 100,
    int offset = 0,
  }) async {
    final resp = await _client.get(
      '$_kBase/history',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (category != null) 'category': category,
      },
    );
    _checkStatus(resp.statusCode, resp.body);
    return _decodeList(resp.body)
        .cast<Map<String, dynamic>>()
        .map(MedicalHistoryModel.fromJson)
        .toList();
  }

  Future<MedicalHistoryModel> createMedicalHistory(
      Map<String, dynamic> json) async {
    final resp = await _client.post(
      '$_kBase/history',
      body: jsonEncode(json),
    );
    _checkStatus(resp.statusCode, resp.body);
    return MedicalHistoryModel.fromJson(_decode(resp.body));
  }

  Future<MedicalHistoryModel> updateMedicalHistory(
      String id, Map<String, dynamic> json) async {
    final resp = await _client.put(
      '$_kBase/history/$id',
      body: jsonEncode(json),
    );
    _checkStatus(resp.statusCode, resp.body);
    return MedicalHistoryModel.fromJson(_decode(resp.body));
  }

  Future<void> deleteHistoryEntry(String id) async {
    final resp = await _client.delete('$_kBase/history/$id');
    _checkDelete(resp.statusCode);
  }

  // ─── Prescriptions ────────────────────────────────────────────────────────

  Future<List<PrescriptionModel>> getPrescriptions({
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await _client.get(
      '$_kBase/prescriptions',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    _checkStatus(resp.statusCode, resp.body);
    return _decodeList(resp.body)
        .cast<Map<String, dynamic>>()
        .map(PrescriptionModel.fromJson)
        .toList();
  }

  Future<PrescriptionModel> createPrescription(
      Map<String, dynamic> json) async {
    // Backend uses multipart form (metadata field = JSON string, optional file).
    // For metadata-only creation send as regular JSON — backend also accepts
    // direct JSON body when no file is attached.
    final resp = await _client.post(
      '$_kBase/prescriptions',
      body: jsonEncode(json),
    );
    _checkStatus(resp.statusCode, resp.body);
    return PrescriptionModel.fromJson(_decode(resp.body));
  }

  Future<void> deletePrescription(String id) async {
    final resp = await _client.delete('$_kBase/prescriptions/$id');
    _checkDelete(resp.statusCode);
  }

  // ─── Medical Images ───────────────────────────────────────────────────────

  Future<List<MedicalImageModel>> getMedicalImages({
    String? imageType,
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await _client.get(
      '$_kBase/images',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (imageType != null) 'image_type': imageType,
      },
    );
    _checkStatus(resp.statusCode, resp.body);
    return _decodeList(resp.body)
        .cast<Map<String, dynamic>>()
        .map(MedicalImageModel.fromJson)
        .toList();
  }

  Future<MedicalImageModel> createMedicalImage(
      Map<String, dynamic> json) async {
    // Metadata-only upload (no file). Backend form field `metadata` = JSON string.
    // We POST as JSON body for simplicity when no file is involved.
    final resp = await _client.post(
      '$_kBase/images',
      body: jsonEncode(json),
    );
    _checkStatus(resp.statusCode, resp.body);
    return MedicalImageModel.fromJson(_decode(resp.body));
  }

  Future<void> deleteMedicalImage(String id) async {
    final resp = await _client.delete('$_kBase/images/$id');
    _checkDelete(resp.statusCode);
  }

  // ─── Push external timeline event ────────────────────────────────────────
  // Called from mobile after symptom checker / emergency / chatbot completes.
  // Backend endpoint: POST /api/v1/health-records/timeline/external
  // Body is multipart form (event_type, title, description?, reference_id?)

  Future<void> pushTimelineEvent({
    required String eventType,
    required String title,
    String? description,
    String? referenceId,
  }) async {
    try {
      final json = <String, dynamic>{
        'event_type': eventType,
        'title': title,
        if (description != null) 'description': description,
        if (referenceId != null) 'reference_id': referenceId,
      };
      final resp = await _client.post(
        '$_kBase/timeline/external',
        body: jsonEncode(json),
      );
      if (resp.statusCode >= 400) {
        SimpleApiClient.log(
            'pushTimelineEvent: ${resp.statusCode} — ${resp.body}');
      }
    } catch (e) {
      SimpleApiClient.log('pushTimelineEvent error: $e');
    }
  }

  // ─── Timeline ─────────────────────────────────────────────────────────────

  Future<List<TimelineEventModel>> getTimeline({
    String? eventType,
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await _client.get(
      '$_kBase/timeline',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (eventType != null) 'event_type': eventType,
      },
    );
    _checkStatus(resp.statusCode, resp.body);
    // Backend returns { total, events: [...] }
    final body = _decode(resp.body);
    final events = (body['events'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(TimelineEventModel.fromJson)
        .toList();
    return events;
  }
}
