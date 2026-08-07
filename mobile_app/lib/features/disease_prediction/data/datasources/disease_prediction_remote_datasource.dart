import 'dart:convert';

import '../../../../core/network/dio_client.dart';
import '../../../../constants/api_constants.dart';
import '../models/disease_prediction_api_models.dart';

/// Remote data source — calls the real FastAPI symptom-checker backend.
class DiseasePredictionRemoteDataSource {
  final SimpleApiClient _client;

  const DiseasePredictionRemoteDataSource(this._client);

  /// POST /api/v1/symptom-checker/predict
  Future<SymptomCheckApiResponse> predict(
      SymptomCheckApiRequest request) async {
    final body = jsonEncode(request.toJson());
    final response = await _client.post(
      ApiConstants.symptomCheckPredictPath,
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SymptomCheckApiResponse.fromJson(json);
    }

    // Surface validation / server errors as readable messages.
    String detail = 'Prediction failed (${response.statusCode}).';
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['detail'] is String) {
        detail = json['detail'] as String;
      } else if (json['detail'] is List) {
        // FastAPI 422 validation errors list
        final errors = (json['detail'] as List)
            .map((e) => (e as Map)['msg']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .join('; ');
        if (errors.isNotEmpty) detail = errors;
      } else if (json['message'] is String) {
        detail = json['message'] as String;
      }
    } catch (_) {}
    throw Exception(detail);
  }
}
