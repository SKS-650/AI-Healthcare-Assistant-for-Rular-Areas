/// All enums used across the offline module.
library;

// ─────────────────────────────────────────────────────────────────────────────
// Sync status
// ─────────────────────────────────────────────────────────────────────────────

enum SyncStatus {
  idle,
  syncing,
  success,
  failed,
  partial;

  bool get isActive => this == SyncStatus.syncing;
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue operation type
// ─────────────────────────────────────────────────────────────────────────────

enum OperationType {
  createRecord,
  updateRecord,
  deleteRecord,
  uploadReport,
  saveAssessment,
  saveChatMessage,
  saveBookmark,
  updateProfile,
  savePreference;

  String get label => switch (this) {
        OperationType.createRecord    => 'Create Record',
        OperationType.updateRecord    => 'Update Record',
        OperationType.deleteRecord    => 'Delete Record',
        OperationType.uploadReport    => 'Upload Report',
        OperationType.saveAssessment  => 'Save Assessment',
        OperationType.saveChatMessage => 'Save Chat',
        OperationType.saveBookmark    => 'Save Bookmark',
        OperationType.updateProfile   => 'Update Profile',
        OperationType.savePreference  => 'Save Preference',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue item status
// ─────────────────────────────────────────────────────────────────────────────

enum QueueItemStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled;

  bool get isPending    => this == QueueItemStatus.pending;
  bool get isCompleted  => this == QueueItemStatus.completed;
  bool get isFailed     => this == QueueItemStatus.failed;
}

// ─────────────────────────────────────────────────────────────────────────────
// Conflict resolution strategy
// ─────────────────────────────────────────────────────────────────────────────

enum ConflictResolution {
  latestWins,
  localWins,
  remoteWins,
  manual;
}

// ─────────────────────────────────────────────────────────────────────────────
// Chatbot source (online vs offline)
// ─────────────────────────────────────────────────────────────────────────────

enum ChatbotSource {
  online,
  offlineKnowledgeBase,
  offlineRule;
}

// ─────────────────────────────────────────────────────────────────────────────
// Download status for cached assets
// ─────────────────────────────────────────────────────────────────────────────

enum DownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
  failed;

  bool get isReady => this == DownloadStatus.downloaded;
}
