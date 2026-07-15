/// Aggregate statistics shown on the Offline Dashboard.
class OfflineStats {
  const OfflineStats({
    required this.pendingQueueItems,
    required this.cachedArticles,
    required this.cachedSymptomResults,
    required this.cachedChatMessages,
    required this.cachedApiResponses,
    required this.totalCacheSizeKb,
    required this.lastSyncAt,
    required this.syncHistoryCount,
  });

  final int pendingQueueItems;
  final int cachedArticles;
  final int cachedSymptomResults;
  final int cachedChatMessages;
  final int cachedApiResponses;
  final double totalCacheSizeKb;
  final DateTime? lastSyncAt;
  final int syncHistoryCount;

  static const OfflineStats empty = OfflineStats(
    pendingQueueItems:   0,
    cachedArticles:      0,
    cachedSymptomResults: 0,
    cachedChatMessages:  0,
    cachedApiResponses:  0,
    totalCacheSizeKb:    0,
    lastSyncAt:          null,
    syncHistoryCount:    0,
  );
}
