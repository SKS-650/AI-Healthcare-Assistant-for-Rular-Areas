import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/models.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class SettingsState {
  final bool isLoading;
  final String? error;
  final List<SystemSetting> settings;
  final List<String> categories;
  final String? selectedCategory;
  final Map<String, dynamic>? symptomCheckerConfig;
  final Map<String, dynamic>? chatbotConfig;
  final Map<String, dynamic>? emergencyConfig;
  final bool isSaving;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.settings = const [],
    this.categories = const [],
    this.selectedCategory,
    this.symptomCheckerConfig,
    this.chatbotConfig,
    this.emergencyConfig,
    this.isSaving = false,
  });

  List<SystemSetting> get filteredSettings {
    if (selectedCategory == null) return settings;
    return settings.where((s) => s.category == selectedCategory).toList();
  }

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<SystemSetting>? settings,
    List<String>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    Map<String, dynamic>? symptomCheckerConfig,
    Map<String, dynamic>? chatbotConfig,
    Map<String, dynamic>? emergencyConfig,
    bool? isSaving,
  }) =>
      SettingsState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        settings: settings ?? this.settings,
        categories: categories ?? this.categories,
        selectedCategory:
            clearCategory ? null : (selectedCategory ?? this.selectedCategory),
        symptomCheckerConfig:
            symptomCheckerConfig ?? this.symptomCheckerConfig,
        chatbotConfig: chatbotConfig ?? this.chatbotConfig,
        emergencyConfig: emergencyConfig ?? this.emergencyConfig,
        isSaving: isSaving ?? this.isSaving,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final settingsData = (await ApiClient.instance.get('/admin/settings')).data as Map<String, dynamic>;

      Map<String, dynamic>? symptomCfg, chatbotCfg, emergencyCfg;
      try {
        final r = await ApiClient.instance.get('/admin/symptom-checker/config');
        symptomCfg = r.data as Map<String, dynamic>?;
      } catch (_) {}
      try {
        final r = await ApiClient.instance.get('/admin/chatbot/config');
        chatbotCfg = r.data as Map<String, dynamic>?;
      } catch (_) {}
      try {
        final r = await ApiClient.instance.get('/admin/emergency/config');
        emergencyCfg = r.data as Map<String, dynamic>?;
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        settings: (settingsData['settings'] as List)
            .cast<Map<String, dynamic>>()
            .map(SystemSetting.fromJson)
            .toList(),
        categories: (settingsData['categories'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        symptomCheckerConfig: symptomCfg,
        chatbotConfig: chatbotCfg,
        emergencyConfig: emergencyCfg,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void selectCategory(String? category) {
    state = category == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(selectedCategory: category);
  }

  Future<bool> updateSetting(String key, String value) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final resp = await ApiClient.instance
          .patch('/admin/settings/$key', data: {'value': value});
      final updated = SystemSetting.fromJson(resp.data as Map<String, dynamic>);
      final updatedList = state.settings.map((s) {
        return s.key == key ? updated : s;
      }).toList();
      state = state.copyWith(isSaving: false, settings: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: errorMessage(e));
      return false;
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
        (ref) => SettingsNotifier());
