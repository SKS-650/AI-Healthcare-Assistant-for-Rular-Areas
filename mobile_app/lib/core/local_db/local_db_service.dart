/// Local database service.
///
/// Storage backends (all cross-platform — Web + Android + iOS + Desktop):
///   Hive          → conversations, response cache, voice history,
///                   medical history, medical images, medical profile,
///                   timeline events,
///                   offline sync queue, symptom assessment cache,
///                   offline chat cache, API response cache, sync history
///   SharedPreferences → user settings (language, theme, TTS toggle,
///                        offline module settings)
///
/// Why no sqflite / path_provider?
///   Both crash on Flutter Web. Hive.initFlutter() with no arguments
///   picks the right path automatically on every platform.
library;

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/medical_chatbot/data/models/chat_message_model.dart';
import '../../features/medical_chatbot/data/models/conversation_model.dart';
import '../../features/medical_chatbot/domain/entities/chat_message.dart';
import '../../features/health_records/data/models/medical_history_model.dart';
import '../../features/health_records/data/models/medical_image_model.dart';
import '../../features/health_records/data/models/medical_profile_model.dart';
import '../../features/health_records/data/models/timeline_event_model.dart';
import '../../features/health_education/data/models/health_article_model.dart';
import '../../features/health_education/domain/entities/education_dashboard.dart';
import '../../features/health_education/data/models/education_dashboard_model.dart';
// ── Offline module models ──────────────────────────────────────────────────
import '../../features/offline/data/models/sync_queue_item_model.dart';
import '../../features/offline/data/models/offline_symptom_result_model.dart';
import '../../features/offline/data/models/offline_chat_entry_model.dart';
import '../../features/offline/data/models/sync_history_entry_model.dart';
import '../../features/offline/domain/entities/cached_api_response.dart';
import '../../features/offline/domain/entities/offline_settings.dart';
import '../../features/offline/domain/enums/offline_enums.dart';

const _kConversations      = 'med_conversations';
const _kCachedResponses    = 'med_response_cache';
const _kVoiceHistory       = 'med_voice_history';
// ── Medical Records offline boxes ─────────────────────────────────────────
const _kMedicalProfile     = 'phr_profile';
const _kMedicalHistory     = 'phr_history';
const _kMedicalImages      = 'phr_images';
const _kTimelineEvents     = 'phr_timeline';
// ── Health Education offline boxes ────────────────────────────────────────
const _kEduOfflineArticles  = 'edu_offline_articles';
const _kEduBookmarks        = 'edu_bookmarks';
const _kEduReadProgress     = 'edu_read_progress';
const _kEduDashboardCache   = 'edu_dashboard_cache';
// ── Offline module boxes ──────────────────────────────────────────────────
const _kSyncQueue           = 'offline_sync_queue';
const _kSymptomCache        = 'offline_symptom_cache';
const _kOfflineChatCache    = 'offline_chat_cache';
const _kApiResponseCache    = 'offline_api_cache';
const _kSyncHistory         = 'offline_sync_history';

class LocalDbService {
  LocalDbService._();
  static final LocalDbService instance = LocalDbService._();

  Box<dynamic>? _convBox;
  Box<dynamic>? _cacheBox;
  Box<dynamic>? _voiceBox;
  // ── Medical Records boxes ──────────────────────────────────────────────────
  Box<dynamic>? _profileBox;
  Box<dynamic>? _historyBox;
  Box<dynamic>? _imagesBox;
  Box<dynamic>? _timelineBox;
  // ── Health Education boxes ─────────────────────────────────────────────────
  Box<dynamic>? _eduOfflineBox;
  Box<dynamic>? _eduBookmarksBox;
  Box<dynamic>? _eduProgressBox;
  Box<dynamic>? _eduDashboardBox;
  // ── Offline module boxes ───────────────────────────────────────────────────
  Box<dynamic>? _syncQueueBox;
  Box<dynamic>? _symptomCacheBox;
  Box<dynamic>? _offlineChatBox;
  Box<dynamic>? _apiCacheBox;
  Box<dynamic>? _syncHistoryBox;
  SharedPreferences? _prefs;
  bool _initialized = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // No path argument → Hive auto-picks the right directory per platform
      // Web   : IndexedDB
      // Mobile: getApplicationDocumentsDirectory (handled inside hive_flutter)
      await Hive.initFlutter();

      _convBox  = await Hive.openBox(_kConversations);
      _cacheBox = await Hive.openBox(_kCachedResponses);
      _voiceBox = await Hive.openBox(_kVoiceHistory);
      // Medical Records offline boxes
      _profileBox  = await Hive.openBox(_kMedicalProfile);
      _historyBox  = await Hive.openBox(_kMedicalHistory);
      _imagesBox   = await Hive.openBox(_kMedicalImages);
      _timelineBox = await Hive.openBox(_kTimelineEvents);
      // Health Education offline boxes
      _eduOfflineBox   = await Hive.openBox(_kEduOfflineArticles);
      _eduBookmarksBox = await Hive.openBox(_kEduBookmarks);
      _eduProgressBox  = await Hive.openBox(_kEduReadProgress);
      _eduDashboardBox = await Hive.openBox(_kEduDashboardCache);
      // Offline module boxes
      _syncQueueBox     = await Hive.openBox(_kSyncQueue);
      _symptomCacheBox  = await Hive.openBox(_kSymptomCache);
      _offlineChatBox   = await Hive.openBox(_kOfflineChatCache);
      _apiCacheBox      = await Hive.openBox(_kApiResponseCache);
      _syncHistoryBox   = await Hive.openBox(_kSyncHistory);
      _prefs    = await SharedPreferences.getInstance();
    } catch (_) {
      // Non-fatal — app continues without local persistence.
    }
    _initialized = true;
  }

  Future<void> _ensureInit() async {
    if (!_initialized) await initialize();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Conversations
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveConversation(ConversationModel conv) async {
    await _ensureInit();
    if (_convBox == null) return;
    await _convBox!.put(conv.id, jsonEncode({
      'id':        conv.id,
      'title':     conv.title,
      'updatedAt': conv.updatedAt.toIso8601String(),
      'messages':  conv.messages.map(_msgToMap).toList(),
    }));
  }

  Future<List<ConversationModel>> loadConversations() async {
    await _ensureInit();
    if (_convBox == null) return [];
    final result = <ConversationModel>[];
    for (final raw in _convBox!.values) {
      try {
        final map = jsonDecode(raw as String) as Map<String, dynamic>;
        result.add(_convFromMap(map));
      } catch (_) {}
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  Future<void> deleteConversation(String id) async {
    await _ensureInit();
    await _convBox?.delete(id);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Messages (stored inside conversations — no separate table)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveMessages(
      String conversationId, List<ChatMessage> messages) async {
    // Messages are persisted via saveConversation — this is a no-op stub
    // kept so existing call-sites compile without changes.
  }

  Future<List<Map<String, dynamic>>> searchMessages(String query) async =>
      [];

  // ─────────────────────────────────────────────────────────────────────────
  // Response cache
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> cacheResponse(String query, String response) async {
    await _ensureInit();
    if (_cacheBox == null) return;
    final key =
        query.toLowerCase().trim().hashCode.abs().toRadixString(16);
    await _cacheBox!.put(key, jsonEncode({
      'query': query,
      'response': response,
      'at': DateTime.now().toIso8601String(),
    }));
    if (_cacheBox!.length > 500) await _cacheBox!.deleteAt(0);
  }

  Future<String?> getCachedResponse(String query) async {
    await _ensureInit();
    if (_cacheBox == null) return null;
    final key =
        query.toLowerCase().trim().hashCode.abs().toRadixString(16);
    final raw = _cacheBox!.get(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw as String) as Map<String, dynamic>)['response']
          as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearResponseCache() async {
    await _ensureInit();
    await _cacheBox?.clear();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Settings  (SharedPreferences — works on all platforms including web)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveSetting(String key, dynamic value) async {
    await _ensureInit();
    final p = _prefs;
    if (p == null) return;
    if (value is String)      { await p.setString(key, value); }
    else if (value is bool)   { await p.setBool(key, value); }
    else if (value is int)    { await p.setInt(key, value); }
    else if (value is double) { await p.setDouble(key, value); }
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    final val = _prefs?.get(key);
    if (val is T) return val;
    return defaultValue;
  }

  // Typed convenience getters / setters
  String get selectedLanguage =>
      getSetting<String>('language', defaultValue: 'en') ?? 'en';
  bool get isDarkMode =>
      getSetting<bool>('dark_mode', defaultValue: false) ?? false;
  bool get ttsEnabled =>
      getSetting<bool>('tts_enabled', defaultValue: true) ?? true;
  bool get saveHistoryFlag =>
      getSetting<bool>('save_history', defaultValue: true) ?? true;

  Future<void> setLanguage(String c)     => saveSetting('language',    c);
  Future<void> setDarkMode(bool v)       => saveSetting('dark_mode',   v);
  Future<void> setTtsEnabled(bool v)     => saveSetting('tts_enabled', v);
  Future<void> setSaveHistory(bool v)    => saveSetting('save_history', v);

  // ─────────────────────────────────────────────────────────────────────────
  // Voice history
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> addVoiceTranscript(
      String transcript, String language) async {
    await _ensureInit();
    if (_voiceBox == null) return;
    final all = _voiceBox!.values.toList();
    all.insert(0, jsonEncode({
      'text': transcript,
      'language': language,
      'ts': DateTime.now().toIso8601String(),
    }));
    await _voiceBox!.clear();
    for (final e in all.take(50)) {
      await _voiceBox!.add(e);
    }
  }

  Future<List<Map<String, dynamic>>> getVoiceHistory() async {
    await _ensureInit();
    if (_voiceBox == null) return [];
    return _voiceBox!.values.map((e) {
      try {
        return jsonDecode(e as String) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Medical Records — offline cache (Hive)
  // ─────────────────────────────────────────────────────────────────────────

  // ── Profile ───────────────────────────────────────────────────────────────

  /// Persist the user's medical profile locally (single record per box).
  Future<void> saveMedicalProfile(MedicalProfileModel profile) async {
    await _ensureInit();
    if (_profileBox == null) return;
    await _profileBox!.put('profile', jsonEncode(profile.toJson()
      ..addAll({
        'id':         profile.id,
        'user_id':    profile.userId,
        'created_at': profile.createdAt.toIso8601String(),
        'updated_at': profile.updatedAt.toIso8601String(),
      })));
  }

  Future<MedicalProfileModel?> loadMedicalProfile() async {
    await _ensureInit();
    if (_profileBox == null) return null;
    final raw = _profileBox!.get('profile');
    if (raw == null) return null;
    try {
      return MedicalProfileModel.fromJson(
          jsonDecode(raw as String) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Medical History ───────────────────────────────────────────────────────

  Future<void> saveMedicalHistory(List<MedicalHistoryModel> entries) async {
    await _ensureInit();
    if (_historyBox == null) return;
    await _historyBox!.clear();
    for (final entry in entries) {
      await _historyBox!.put(entry.id, jsonEncode(entry.toLocalJson()));
    }
  }

  Future<List<MedicalHistoryModel>> loadMedicalHistory() async {
    await _ensureInit();
    if (_historyBox == null) return [];
    final result = <MedicalHistoryModel>[];
    for (final raw in _historyBox!.values) {
      try {
        result.add(MedicalHistoryModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> upsertHistoryEntry(MedicalHistoryModel entry) async {
    await _ensureInit();
    if (_historyBox == null) return;
    await _historyBox!.put(entry.id, jsonEncode(entry.toLocalJson()));
  }

  Future<void> deleteHistoryEntry(String id) async {
    await _ensureInit();
    await _historyBox?.delete(id);
  }

  // ── Medical Images ────────────────────────────────────────────────────────

  /// Cache image metadata (not the binary file — just the record).
  Future<void> saveMedicalImages(List<MedicalImageModel> images) async {
    await _ensureInit();
    if (_imagesBox == null) return;
    await _imagesBox!.clear();
    for (final img in images) {
      await _imagesBox!.put(
          img.id,
          jsonEncode({
            'id':           img.id,
            'user_id':      img.userId,
            'title':        img.title,
            'image_type':   img.imageType,
            'description':  img.description,
            'body_part':    img.bodyPart,
            'doctor_name':  img.doctorName,
            'hospital_name':img.hospitalName,
            'scan_date':    img.scanDate?.toIso8601String(),
            'tags':         img.tags,
            'file_url':     img.fileUrl,
            'file_original_name': img.fileOriginalName,
            'file_size_bytes': img.fileSizeBytes,
            'created_at':   img.createdAt.toIso8601String(),
          }));
    }
  }

  Future<List<MedicalImageModel>> loadMedicalImages() async {
    await _ensureInit();
    if (_imagesBox == null) return [];
    final result = <MedicalImageModel>[];
    for (final raw in _imagesBox!.values) {
      try {
        result.add(MedicalImageModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> deleteMedicalImage(String id) async {
    await _ensureInit();
    await _imagesBox?.delete(id);
  }

  // ── Timeline ──────────────────────────────────────────────────────────────

  Future<void> saveTimelineEvents(List<TimelineEventModel> events) async {
    await _ensureInit();
    if (_timelineBox == null) return;
    await _timelineBox!.clear();
    for (final event in events.take(100)) {
      // cap at 100 most recent events
      await _timelineBox!.put(event.id, jsonEncode(event.toLocalJson()));
    }
  }

  Future<List<TimelineEventModel>> loadTimelineEvents() async {
    await _ensureInit();
    if (_timelineBox == null) return [];
    final result = <TimelineEventModel>[];
    for (final raw in _timelineBox!.values) {
      try {
        result.add(TimelineEventModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return result;
  }

  Future<void> clearMedicalRecords() async {
    await _ensureInit();
    await _profileBox?.clear();
    await _historyBox?.clear();
    await _imagesBox?.clear();
    await _timelineBox?.clear();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Utilities
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _ensureInit();
    await _convBox?.clear();
    await _cacheBox?.clear();
    await _voiceBox?.clear();
    await clearMedicalRecords();
    await clearHealthEducation();
    await clearOfflineData();
  }

  Future<Map<String, int>> getStats() async {
    await _ensureInit();
    return {
      'conversations':    _convBox?.length          ?? 0,
      'cached_responses': _cacheBox?.length         ?? 0,
      'voice_history':    _voiceBox?.length         ?? 0,
      'medical_history':  _historyBox?.length       ?? 0,
      'medical_images':   _imagesBox?.length        ?? 0,
      'timeline_events':  _timelineBox?.length      ?? 0,
      'edu_offline':      _eduOfflineBox?.length    ?? 0,
      'edu_bookmarks':    _eduBookmarksBox?.length  ?? 0,
      'sync_queue':       _syncQueueBox?.length     ?? 0,
      'symptom_cache':    _symptomCacheBox?.length  ?? 0,
      'offline_chat':     _offlineChatBox?.length   ?? 0,
      'api_cache':        _apiCacheBox?.length      ?? 0,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Health Education — offline articles
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveOfflineArticle(HealthArticleModel article) async {
    await _ensureInit();
    if (_eduOfflineBox == null) return;
    await _eduOfflineBox!.put(article.id, jsonEncode(article.toJson()));
  }

  Future<List<HealthArticleModel>> loadOfflineArticles() async {
    await _ensureInit();
    if (_eduOfflineBox == null) return [];
    final result = <HealthArticleModel>[];
    for (final raw in _eduOfflineBox!.values) {
      try {
        result.add(HealthArticleModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    return result;
  }

  Future<HealthArticleModel?> getOfflineArticle(String id) async {
    await _ensureInit();
    final raw = _eduOfflineBox?.get(id);
    if (raw == null) return null;
    try {
      return HealthArticleModel.fromJson(
          jsonDecode(raw as String) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> removeOfflineArticle(String id) async {
    await _ensureInit();
    await _eduOfflineBox?.delete(id);
  }

  Future<bool> isArticleOffline(String id) async {
    await _ensureInit();
    return _eduOfflineBox?.containsKey(id) ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Health Education — bookmarks (local fallback)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> addLocalBookmark(String articleId) async {
    await _ensureInit();
    if (_eduBookmarksBox == null) return;
    await _eduBookmarksBox!.put(articleId, articleId);
  }

  Future<void> removeLocalBookmark(String articleId) async {
    await _ensureInit();
    // bookmarkId format is "local-{articleId}"
    final id = articleId.replaceFirst('local-', '');
    await _eduBookmarksBox?.delete(id);
    await _eduBookmarksBox?.delete(articleId);
  }

  Future<List<String>> loadLocalBookmarkIds() async {
    await _ensureInit();
    if (_eduBookmarksBox == null) return [];
    return _eduBookmarksBox!.values.cast<String>().toList();
  }

  Future<List<HealthArticleModel>> loadBookmarkedArticles() async {
    final ids = await loadLocalBookmarkIds();
    final result = <HealthArticleModel>[];
    for (final id in ids) {
      final article = await getOfflineArticle(id);
      if (article != null) result.add(article);
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Health Education — reading progress
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveReadingProgress({
    required String articleId,
    required int position,
    bool isCompleted = false,
  }) async {
    await _ensureInit();
    if (_eduProgressBox == null) return;
    await _eduProgressBox!.put(articleId, jsonEncode({
      'article_id':   articleId,
      'position':     position,
      'is_completed': isCompleted,
      'updated_at':   DateTime.now().toIso8601String(),
    }));
  }

  Future<Map<String, dynamic>?> getReadingProgress(String articleId) async {
    await _ensureInit();
    final raw = _eduProgressBox?.get(articleId);
    if (raw == null) return null;
    try {
      return jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Health Education — dashboard cache
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveEducationDashboard(Map<String, dynamic> data) async {
    await _ensureInit();
    if (_eduDashboardBox == null) return;
    await _eduDashboardBox!.put('dashboard', jsonEncode(data));
  }

  Future<EducationDashboard?> loadEducationDashboard() async {
    await _ensureInit();
    final raw = _eduDashboardBox?.get('dashboard');
    if (raw == null) return null;
    try {
      return EducationDashboardModel.fromJson(
          jsonDecode(raw as String) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearHealthEducation() async {
    await _ensureInit();
    await _eduOfflineBox?.clear();
    await _eduBookmarksBox?.clear();
    await _eduProgressBox?.clear();
    await _eduDashboardBox?.clear();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offline Module — Sync Queue
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> enqueueSyncItem(SyncQueueItemModel item) async {
    await _ensureInit();
    if (_syncQueueBox == null) return;
    await _syncQueueBox!.put(item.id, jsonEncode(item.toJson()));
  }

  Future<List<SyncQueueItemModel>> loadSyncQueue() async {
    await _ensureInit();
    if (_syncQueueBox == null) return [];
    final result = <SyncQueueItemModel>[];
    for (final raw in _syncQueueBox!.values) {
      try {
        result.add(SyncQueueItemModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }

  Future<List<SyncQueueItemModel>> loadPendingSyncQueue() async {
    final all = await loadSyncQueue();
    return all
        .where((item) => item.status == QueueItemStatus.pending ||
            item.status == QueueItemStatus.failed)
        .where((item) => item.canRetry)
        .toList();
  }

  Future<void> updateSyncItem(SyncQueueItemModel item) async {
    await _ensureInit();
    if (_syncQueueBox == null) return;
    await _syncQueueBox!.put(item.id, jsonEncode(item.toJson()));
  }

  Future<void> deleteSyncItem(String id) async {
    await _ensureInit();
    await _syncQueueBox?.delete(id);
  }

  Future<void> clearCompletedSyncItems() async {
    await _ensureInit();
    if (_syncQueueBox == null) return;
    final all = await loadSyncQueue();
    for (final item in all) {
      if (item.status == QueueItemStatus.completed) {
        await _syncQueueBox!.delete(item.id);
      }
    }
  }

  Future<int> pendingSyncCount() async {
    final pending = await loadPendingSyncQueue();
    return pending.length;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offline Module — Symptom Assessment Cache
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveOfflineSymptomResult(OfflineSymptomResultModel result) async {
    await _ensureInit();
    if (_symptomCacheBox == null) return;
    await _symptomCacheBox!.put(result.id, jsonEncode(result.toJson()));
    // Keep only the 50 most recent assessments
    if (_symptomCacheBox!.length > 50) {
      final keys = _symptomCacheBox!.keys.toList();
      await _symptomCacheBox!.delete(keys.first);
    }
  }

  Future<List<OfflineSymptomResultModel>> loadOfflineSymptomResults({
    int limit = 20,
  }) async {
    await _ensureInit();
    if (_symptomCacheBox == null) return [];
    final result = <OfflineSymptomResultModel>[];
    for (final raw in _symptomCacheBox!.values) {
      try {
        result.add(OfflineSymptomResultModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result.take(limit).toList();
  }

  Future<List<OfflineSymptomResultModel>> loadUnsyncedSymptomResults() async {
    final all = await loadOfflineSymptomResults(limit: 100);
    return all.where((r) => !r.isSynced).toList();
  }

  Future<void> markSymptomResultSynced(String id) async {
    await _ensureInit();
    final raw = _symptomCacheBox?.get(id);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      map['is_synced'] = true;
      await _symptomCacheBox!.put(id, jsonEncode(map));
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offline Module — Chat Cache
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveOfflineChatEntry(OfflineChatEntryModel entry) async {
    await _ensureInit();
    if (_offlineChatBox == null) return;
    await _offlineChatBox!.put(entry.id, jsonEncode(entry.toJson()));
    if (_offlineChatBox!.length > 200) {
      final keys = _offlineChatBox!.keys.toList();
      await _offlineChatBox!.delete(keys.first);
    }
  }

  Future<List<OfflineChatEntryModel>> loadOfflineChatEntries({
    int limit = 50,
  }) async {
    await _ensureInit();
    if (_offlineChatBox == null) return [];
    final result = <OfflineChatEntryModel>[];
    for (final raw in _offlineChatBox!.values) {
      try {
        result.add(OfflineChatEntryModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result.take(limit).toList();
  }

  Future<List<OfflineChatEntryModel>> loadUnsyncedChatEntries() async {
    final all = await loadOfflineChatEntries(limit: 200);
    return all.where((e) => !e.isSynced).toList();
  }

  Future<void> markChatEntrySynced(String id) async {
    await _ensureInit();
    final raw = _offlineChatBox?.get(id);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      map['is_synced'] = true;
      await _offlineChatBox!.put(id, jsonEncode(map));
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offline Module — API Response Cache (with TTL)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> cacheApiResponseEntry(CachedApiResponse entry) async {
    await _ensureInit();
    if (_apiCacheBox == null) return;
    await _apiCacheBox!.put(entry.cacheKey, jsonEncode({
      'id':         entry.id,
      'cache_key':  entry.cacheKey,
      'response':   entry.response,
      'created_at': entry.createdAt.toIso8601String(),
      'expires_at': entry.expiresAt.toIso8601String(),
    }));
    // Evict oldest entries if over 300
    if (_apiCacheBox!.length > 300) {
      await _apiCacheBox!.deleteAt(0);
    }
  }

  Future<CachedApiResponse?> getApiResponseEntry(String cacheKey) async {
    await _ensureInit();
    final raw = _apiCacheBox?.get(cacheKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      final entry = CachedApiResponse(
        id:        map['id'] as String,
        cacheKey:  map['cache_key'] as String,
        response:  map['response'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        expiresAt: DateTime.parse(map['expires_at'] as String),
      );
      // Evict expired entries on read
      if (entry.isExpired) {
        await _apiCacheBox!.delete(cacheKey);
        return null;
      }
      return entry;
    } catch (_) {
      return null;
    }
  }

  Future<void> evictExpiredApiCache() async {
    await _ensureInit();
    if (_apiCacheBox == null) return;
    final keysToDelete = <dynamic>[];
    for (final key in _apiCacheBox!.keys) {
      final raw = _apiCacheBox!.get(key);
      if (raw == null) continue;
      try {
        final map = jsonDecode(raw as String) as Map<String, dynamic>;
        final expiresAt = DateTime.parse(map['expires_at'] as String);
        if (DateTime.now().isAfter(expiresAt)) keysToDelete.add(key);
      } catch (_) {
        keysToDelete.add(key);
      }
    }
    for (final k in keysToDelete) {
      await _apiCacheBox!.delete(k);
    }
  }

  Future<int> apiCacheCount() async {
    await _ensureInit();
    return _apiCacheBox?.length ?? 0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offline Module — Sync History
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> addSyncHistory(SyncHistoryEntryModel entry) async {
    await _ensureInit();
    if (_syncHistoryBox == null) return;
    await _syncHistoryBox!.put(entry.id, jsonEncode(entry.toJson()));
    // Keep only the last 100 history entries
    if (_syncHistoryBox!.length > 100) {
      await _syncHistoryBox!.deleteAt(0);
    }
  }

  Future<List<SyncHistoryEntryModel>> loadSyncHistory({int limit = 30}) async {
    await _ensureInit();
    if (_syncHistoryBox == null) return [];
    final result = <SyncHistoryEntryModel>[];
    for (final raw in _syncHistoryBox!.values) {
      try {
        result.add(SyncHistoryEntryModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result.take(limit).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offline Module — Settings (stored in SharedPreferences)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveOfflineSettings(OfflineSettings settings) async {
    await _ensureInit();
    await saveSetting('offline_enabled',       settings.offlineModeEnabled);
    await saveSetting('offline_auto_sync',     settings.autoSyncEnabled);
    await saveSetting('offline_wifi_only',     settings.syncOnWifiOnly);
    await saveSetting('offline_cache_articles', settings.cacheArticlesForOffline);
    await saveSetting('offline_cache_days',    settings.maxCacheAgeDays);
    if (settings.lastSyncAt != null) {
      await saveSetting('offline_last_sync', settings.lastSyncAt!.toIso8601String());
    }
  }

  OfflineSettings loadOfflineSettings() {
    final lastSyncRaw = getSetting<String>('offline_last_sync');
    return OfflineSettings(
      offlineModeEnabled:      getSetting<bool>('offline_enabled',        defaultValue: true)  ?? true,
      autoSyncEnabled:         getSetting<bool>('offline_auto_sync',      defaultValue: true)  ?? true,
      syncOnWifiOnly:          getSetting<bool>('offline_wifi_only',      defaultValue: false) ?? false,
      cacheArticlesForOffline: getSetting<bool>('offline_cache_articles', defaultValue: true)  ?? true,
      maxCacheAgeDays:         getSetting<int>('offline_cache_days',      defaultValue: 7)     ?? 7,
      lastSyncAt: lastSyncRaw != null ? DateTime.tryParse(lastSyncRaw) : null,
    );
  }

  Future<void> updateLastSyncTime(DateTime time) async {
    await saveSetting('offline_last_sync', time.toIso8601String());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offline Module — Aggregate stats
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getOfflineStats() async {
    await _ensureInit();
    return {
      'sync_queue':        _syncQueueBox?.length    ?? 0,
      'symptom_cache':     _symptomCacheBox?.length ?? 0,
      'offline_chat':      _offlineChatBox?.length  ?? 0,
      'api_cache':         _apiCacheBox?.length     ?? 0,
      'sync_history':      _syncHistoryBox?.length  ?? 0,
    };
  }

  Future<void> clearOfflineData() async {
    await _ensureInit();
    await _syncQueueBox?.clear();
    await _symptomCacheBox?.clear();
    await _offlineChatBox?.clear();
    await _apiCacheBox?.clear();
    // Do NOT clear sync history — user may want to review it.
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> _msgToMap(ChatMessage m) => {
        'id':             m.id,
        'text':           m.text,
        'sender':         m.sender.name,
        'createdAt':      m.createdAt.toIso8601String(),
        'isVoiceMessage': m.isVoiceMessage,
        if (m is ChatMessageModel) ...{
          'is_emergency':        m.isEmergency,
          'follow_up_questions': m.followUpQuestions,
          'mode':    m.isOnlineMode ? 'online' : 'offline',
          'intent':  m.intent,
        },
      };

  ConversationModel _convFromMap(Map<String, dynamic> map) {
    final rawMsgs = (map['messages'] as List?) ?? [];
    return ConversationModel(
      id:       map['id'] as String,
      title:    map['title'] as String,
      messages: rawMsgs
          .map((m) =>
              ChatMessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
