import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class PredictionRecord {
  final String id;
  final String? userId;
  final String? userName;
  final List<String> symptoms;
  final int? age;
  final String? gender;
  final String? predictedDisease;
  final double? confidence;
  final String? riskLevel;
  final int? riskScore;
  final bool isEmergency;
  final DateTime createdAt;

  const PredictionRecord({
    required this.id,
    this.userId,
    this.userName,
    required this.symptoms,
    this.age,
    this.gender,
    this.predictedDisease,
    this.confidence,
    this.riskLevel,
    this.riskScore,
    required this.isEmergency,
    required this.createdAt,
  });

  factory PredictionRecord.fromJson(Map<String, dynamic> j) =>
      PredictionRecord(
        id: j['id']?.toString() ?? '',
        userId: j['user_id'] as String?,
        userName: j['user_name'] as String?,
        symptoms: (j['symptoms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        age: j['age'] as int?,
        gender: j['gender'] as String?,
        predictedDisease: j['predicted_disease'] as String?,
        confidence: (j['confidence'] as num?)?.toDouble(),
        riskLevel: j['risk_level'] as String?,
        riskScore: j['risk_score'] as int?,
        isEmergency: j['is_emergency'] as bool? ?? false,
        createdAt: j['created_at'] != null
            ? DateTime.parse(j['created_at'] as String)
            : DateTime.now(),
      );
}

class DiseasePredictionStats {
  final bool modelLoaded;
  final String? modelVersion;
  final int availableSymptoms;
  final int availableDiseases;
  final int totalPredictions;
  final int emergencyFlags;
  final List<Map<String, dynamic>> topDiseases;
  final Map<String, dynamic> riskDistribution;

  const DiseasePredictionStats({
    required this.modelLoaded,
    this.modelVersion,
    required this.availableSymptoms,
    required this.availableDiseases,
    required this.totalPredictions,
    required this.emergencyFlags,
    required this.topDiseases,
    required this.riskDistribution,
  });

  factory DiseasePredictionStats.fromJson(Map<String, dynamic> j) =>
      DiseasePredictionStats(
        modelLoaded: j['model_loaded'] as bool? ?? false,
        modelVersion: j['model_version'] as String?,
        availableSymptoms: j['available_symptoms'] as int? ?? 0,
        availableDiseases: j['available_diseases'] as int? ?? 0,
        totalPredictions: j['total_predictions'] as int? ?? 0,
        emergencyFlags: j['emergency_flags'] as int? ?? 0,
        topDiseases: (j['top_diseases'] as List?)
                ?.cast<Map<String, dynamic>>()
                .toList() ??
            [],
        riskDistribution:
            Map<String, dynamic>.from(j['risk_distribution'] ?? {}),
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class DiseasePredictionState {
  final bool isLoading;
  final bool isLoadingStats;
  final String? error;
  final List<PredictionRecord> predictions;
  final DiseasePredictionStats? stats;
  final Map<String, dynamic>? config;
  final int total;
  final int page;
  final int pageSize;
  final String? riskFilter;
  final bool? isEmergencyFilter;

  const DiseasePredictionState({
    this.isLoading = false,
    this.isLoadingStats = false,
    this.error,
    this.predictions = const [],
    this.stats,
    this.config,
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.riskFilter,
    this.isEmergencyFilter,
  });

  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);

  DiseasePredictionState copyWith({
    bool? isLoading,
    bool? isLoadingStats,
    String? error,
    bool clearError = false,
    List<PredictionRecord>? predictions,
    DiseasePredictionStats? stats,
    Map<String, dynamic>? config,
    int? total,
    int? page,
    String? riskFilter,
    bool? isEmergencyFilter,
    bool clearRisk = false,
    bool clearEmergency = false,
  }) =>
      DiseasePredictionState(
        isLoading: isLoading ?? this.isLoading,
        isLoadingStats: isLoadingStats ?? this.isLoadingStats,
        error: clearError ? null : (error ?? this.error),
        predictions: predictions ?? this.predictions,
        stats: stats ?? this.stats,
        config: config ?? this.config,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize,
        riskFilter: clearRisk ? null : (riskFilter ?? this.riskFilter),
        isEmergencyFilter:
            clearEmergency ? null : (isEmergencyFilter ?? this.isEmergencyFilter),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DiseasePredictionNotifier
    extends StateNotifier<DiseasePredictionState> {
  DiseasePredictionNotifier() : super(const DiseasePredictionState()) {
    loadStats();
    loadHistory();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoadingStats: true);
    try {
      final resp = await ApiClient.instance
          .get('/admin/disease-prediction/stats');
      state = state.copyWith(
        isLoadingStats: false,
        stats: DiseasePredictionStats.fromJson(
            resp.data as Map<String, dynamic>),
      );
    } catch (e) {
      state = state.copyWith(
          isLoadingStats: false, error: errorMessage(e));
    }
  }

  Future<void> loadHistory({int? page}) async {
    state = state.copyWith(
        isLoading: true, clearError: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{
        'page': state.page,
        'page_size': state.pageSize,
      };
      if (state.riskFilter != null) params['risk_level'] = state.riskFilter;
      if (state.isEmergencyFilter != null) {
        params['is_emergency'] = state.isEmergencyFilter;
      }

      final resp = await ApiClient.instance
          .get('/admin/disease-prediction/history', queryParameters: params);
      final data = resp.data as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        predictions: (data['predictions'] as List)
            .cast<Map<String, dynamic>>()
            .map(PredictionRecord.fromJson)
            .toList(),
        total: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadConfig() async {
    try {
      final resp =
          await ApiClient.instance.get('/admin/symptom-checker/config');
      state = state.copyWith(
          config: resp.data as Map<String, dynamic>);
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
    }
  }

  Future<bool> reloadModel() async {
    try {
      await ApiClient.instance
          .post('/admin/disease-prediction/reload-model', data: {});
      await loadStats();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  void setRiskFilter(String? v) {
    state = v == null
        ? state.copyWith(clearRisk: true, page: 1)
        : state.copyWith(riskFilter: v, page: 1);
    loadHistory();
  }

  void setEmergencyFilter(bool? v) {
    state = v == null
        ? state.copyWith(clearEmergency: true, page: 1)
        : state.copyWith(isEmergencyFilter: v, page: 1);
    loadHistory();
  }

  void goToPage(int p) => loadHistory(page: p);
}

final diseasePredictionProvider = StateNotifierProvider<
    DiseasePredictionNotifier, DiseasePredictionState>(
  (ref) => DiseasePredictionNotifier(),
);
