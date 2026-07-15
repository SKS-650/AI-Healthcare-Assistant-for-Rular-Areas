/// User-facing offline configuration stored locally.
class OfflineSettings {
  const OfflineSettings({
    this.offlineModeEnabled      = true,
    this.autoSyncEnabled         = true,
    this.syncOnWifiOnly          = false,
    this.cacheArticlesForOffline = true,
    this.maxCacheAgeDays         = 7,
    this.lastSyncAt,
  });

  final bool offlineModeEnabled;
  final bool autoSyncEnabled;
  final bool syncOnWifiOnly;
  final bool cacheArticlesForOffline;
  final int maxCacheAgeDays;
  final DateTime? lastSyncAt;

  OfflineSettings copyWith({
    bool? offlineModeEnabled,
    bool? autoSyncEnabled,
    bool? syncOnWifiOnly,
    bool? cacheArticlesForOffline,
    int? maxCacheAgeDays,
    DateTime? lastSyncAt,
  }) =>
      OfflineSettings(
        offlineModeEnabled:      offlineModeEnabled      ?? this.offlineModeEnabled,
        autoSyncEnabled:         autoSyncEnabled         ?? this.autoSyncEnabled,
        syncOnWifiOnly:          syncOnWifiOnly          ?? this.syncOnWifiOnly,
        cacheArticlesForOffline: cacheArticlesForOffline ?? this.cacheArticlesForOffline,
        maxCacheAgeDays:         maxCacheAgeDays         ?? this.maxCacheAgeDays,
        lastSyncAt:              lastSyncAt              ?? this.lastSyncAt,
      );
}
