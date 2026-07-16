import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Dataset item model ────────────────────────────────────────────────────────

class DatasetItem {
  final String id;
  final String name;
  final String datasetType;
  final String version;
  final int? fileSizeKb;
  final int? recordCount;
  final String? description;
  final bool isActive;
  final String? uploadedBy;
  final String? uploaderName;
  final DateTime createdAt;

  const DatasetItem({
    required this.id,
    required this.name,
    required this.datasetType,
    required this.version,
    this.fileSizeKb,
    this.recordCount,
    this.description,
    required this.isActive,
    this.uploadedBy,
    this.uploaderName,
    required this.createdAt,
  });

  factory DatasetItem.fromJson(Map<String, dynamic> j) => DatasetItem(
        id: j['id'] as String,
        name: j['name'] as String,
        datasetType: j['dataset_type'] as String,
        version: j['version'] as String,
        fileSizeKb: j['file_size_kb'] as int?,
        recordCount: j['record_count'] as int?,
        description: j['description'] as String?,
        isActive: j['is_active'] as bool? ?? false,
        uploadedBy: j['uploaded_by'] as String?,
        uploaderName: j['uploader_name'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

// ── Dataset stats model ───────────────────────────────────────────────────────

class DatasetStats {
  final int total;
  final int active;
  final int inactive;
  final Map<String, int> typeCounts;
  const DatasetStats({
    this.total = 0,
    this.active = 0,
    this.inactive = 0,
    this.typeCounts = const {},
  });
  factory DatasetStats.fromJson(Map<String, dynamic> j) => DatasetStats(
        total: j['total_datasets'] as int? ?? 0,
        active: j['active_datasets'] as int? ?? 0,
        inactive: j['inactive_datasets'] as int? ?? 0,
        typeCounts: (j['type_counts'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v as int)),
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class DatasetState {
  final bool isLoading;
  final String? error;
  final List<DatasetItem> items;
  final int total;
  final int page;
  final int pageSize;
  final String? typeFilter;
  final DatasetStats stats;

  const DatasetState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.typeFilter,
    this.stats = const DatasetStats(),
  });

  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);

  DatasetState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<DatasetItem>? items,
    int? total,
    int? page,
    String? typeFilter,
    bool clearType = false,
    DatasetStats? stats,
  }) =>
      DatasetState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        items: items ?? this.items,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize,
        typeFilter: clearType ? null : (typeFilter ?? this.typeFilter),
        stats: stats ?? this.stats,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DatasetNotifier extends StateNotifier<DatasetState> {
  DatasetNotifier() : super(const DatasetState()) {
    load();
  }

  Future<void> load({int? page}) async {
    state = state.copyWith(
        isLoading: true, clearError: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{
        'page': state.page,
        'page_size': state.pageSize,
      };
      if (state.typeFilter != null) params['dataset_type'] = state.typeFilter;

      final results = await Future.wait([
        ApiClient.instance.get('/admin/datasets', queryParameters: params),
        ApiClient.instance.get('/admin/datasets/stats'),
      ]);

      final data  = results[0].data as Map<String, dynamic>;
      final sData = results[1].data as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        items: (data['datasets'] as List)
            .cast<Map<String, dynamic>>()
            .map(DatasetItem.fromJson)
            .toList(),
        total: data['total'] as int? ?? 0,
        stats: DatasetStats.fromJson(sData),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setTypeFilter(String? v) {
    state = v == null
        ? state.copyWith(clearType: true, page: 1)
        : state.copyWith(typeFilter: v, page: 1);
    load();
  }

  void goToPage(int p) => load(page: p);

  Future<String?> createDataset({
    required String name,
    required String datasetType,
    required String version,
    String? description,
  }) async {
    try {
      await ApiClient.instance.post('/admin/datasets', data: {
        'name': name,
        'dataset_type': datasetType,
        'version': version,
        'description': description,
      });
      load();
      return null; // success
    } catch (e) {
      return errorMessage(e);
    }
  }

  Future<String?> activateDataset(String id) async {
    try {
      await ApiClient.instance.patch('/admin/datasets/$id/activate');
      load();
      return null;
    } catch (e) {
      return errorMessage(e);
    }
  }

  Future<String?> deleteDataset(String id) async {
    try {
      await ApiClient.instance.delete('/admin/datasets/$id');
      load();
      return null;
    } catch (e) {
      return errorMessage(e);
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final datasetProvider =
    StateNotifierProvider<DatasetNotifier, DatasetState>(
  (ref) => DatasetNotifier(),
);

const kDatasetTypes = ['symptom', 'chatbot', 'disease', 'faq'];
