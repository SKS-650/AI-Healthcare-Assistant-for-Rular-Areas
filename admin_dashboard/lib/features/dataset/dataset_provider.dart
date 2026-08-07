import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class DatasetVersionItem {
  final String id;
  final String name;
  final String datasetType;
  final String version;
  final int? fileSizeKb;
  final int? recordCount;
  final String? description;
  final bool isActive;
  final String? uploadedBy;
  final DateTime createdAt;

  const DatasetVersionItem({
    required this.id,
    required this.name,
    required this.datasetType,
    required this.version,
    this.fileSizeKb,
    this.recordCount,
    this.description,
    required this.isActive,
    this.uploadedBy,
    required this.createdAt,
  });

  factory DatasetVersionItem.fromJson(Map<String, dynamic> j) =>
      DatasetVersionItem(
        id: j['id'] as String,
        name: j['name'] as String,
        datasetType: j['dataset_type'] as String,
        version: j['version'] as String? ?? '1.0.0',
        fileSizeKb: j['file_size_kb'] as int?,
        recordCount: j['record_count'] as int?,
        description: j['description'] as String?,
        isActive: j['is_active'] as bool? ?? false,
        uploadedBy: j['uploaded_by'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class DatasetState {
  final bool isLoading;
  final String? error;
  final List<DatasetVersionItem> datasets;
  final Map<String, dynamic>? stats;
  final int total;
  final int page;
  final int pageSize;
  final String? typeFilter;

  const DatasetState({
    this.isLoading = false,
    this.error,
    this.datasets = const [],
    this.stats,
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.typeFilter,
  });

  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);

  DatasetState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<DatasetVersionItem>? datasets,
    Map<String, dynamic>? stats,
    int? total,
    int? page,
    String? typeFilter,
    bool clearType = false,
  }) =>
      DatasetState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        datasets: datasets ?? this.datasets,
        stats: stats ?? this.stats,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize,
        typeFilter: clearType ? null : (typeFilter ?? this.typeFilter),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DatasetNotifier extends StateNotifier<DatasetState> {
  DatasetNotifier() : super(const DatasetState()) {
    loadDatasets();
    loadStats();
  }

  Future<void> loadDatasets({int? page, String? typeFilter}) async {
    state = state.copyWith(
        isLoading: true, clearError: true, page: page ?? state.page);
    if (typeFilter != null) {
      state = state.copyWith(typeFilter: typeFilter);
    }
    try {
      final params = <String, dynamic>{
        'page': state.page,
        'page_size': state.pageSize,
      };
      if (state.typeFilter != null) params['dataset_type'] = state.typeFilter;

      final resp = await ApiClient.instance
          .get('/admin/datasets', queryParameters: params);
      final data = resp.data as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        datasets: (data['datasets'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(DatasetVersionItem.fromJson)
            .toList(),
        total: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadStats() async {
    try {
      final resp = await ApiClient.instance.get('/admin/datasets/stats');
      state =
          state.copyWith(stats: resp.data as Map<String, dynamic>);
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
    }
  }

  Future<bool> createDataset({
    required String name,
    required String datasetType,
    String version = '1.0.0',
    String? description,
  }) async {
    try {
      await ApiClient.instance.post('/admin/datasets', data: {
        'name': name,
        'dataset_type': datasetType,
        'version': version,
        if (description != null && description.isNotEmpty)
          'description': description,
      });
      loadDatasets(page: 1);
      loadStats();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  Future<bool> activateDataset(String datasetId) async {
    try {
      await ApiClient.instance
          .patch('/admin/datasets/$datasetId/activate', data: {});
      loadDatasets(page: state.page);
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  Future<bool> deleteDataset(String datasetId) async {
    try {
      await ApiClient.instance.delete('/admin/datasets/$datasetId');
      loadDatasets(page: state.page);
      loadStats();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  void setTypeFilter(String? v) {
    state = v == null
        ? state.copyWith(clearType: true, page: 1)
        : state.copyWith(typeFilter: v, page: 1);
    loadDatasets();
  }

  void goToPage(int p) => loadDatasets(page: p);
}

final datasetProvider =
    StateNotifierProvider<DatasetNotifier, DatasetState>(
        (ref) => DatasetNotifier());
