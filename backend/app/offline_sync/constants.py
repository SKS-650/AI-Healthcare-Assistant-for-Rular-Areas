"""Constants for the offline_sync module."""

# Maximum items per upload batch
MAX_BATCH_SIZE = 100

# Default cache TTL in hours
DEFAULT_CACHE_TTL_HOURS = 24

# Maximum sync history entries kept per user
MAX_HISTORY_ENTRIES = 200

# Operation types recognised by the server
VALID_OPERATION_TYPES = frozenset({
    "create_record",
    "update_record",
    "delete_record",
    "upload_report",
    "save_assessment",
    "save_chat_message",
    "save_bookmark",
    "update_profile",
    "save_preference",
})

# Sync status values
STATUS_SUCCESS = "success"
STATUS_FAILED  = "failed"
STATUS_PARTIAL = "partial"
STATUS_PENDING = "pending"
