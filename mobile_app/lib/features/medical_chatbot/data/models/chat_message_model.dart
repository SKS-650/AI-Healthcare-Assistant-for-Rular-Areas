import '../../domain/entities/chat_message.dart';

/// Extended chat message model that carries backend response metadata.
class ChatMessageModel extends ChatMessage {
  // Backend-enriched fields
  final bool        isEmergency;
  final List<String> followUpQuestions;
  final bool        isOnlineMode;
  final String?     intent;
  final String?     audioBase64;    // base64 MP3 from backend TTS
  final double      confidence;

  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.sender,
    required super.createdAt,
    super.isVoiceMessage,
    this.isEmergency        = false,
    this.followUpQuestions  = const [],
    this.isOnlineMode       = true,
    this.intent,
    this.audioBase64,
    this.confidence         = 0.8,
  });

  // ── fromJson ──────────────────────────────────────────────────────────────

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id:             json['id']?.toString() ?? 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text:           json['text']?.toString() ?? json['content']?.toString() ?? '',
      sender:         (json['sender'] as String?) == 'user'
                          ? ChatSender.user
                          : ChatSender.bot,
      createdAt:      json['createdAt'] != null
                          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
                          : DateTime.now(),
      isVoiceMessage: json['isVoiceMessage'] as bool? ?? false,
      isEmergency:    json['is_emergency']   as bool? ?? false,
      followUpQuestions: (json['follow_up_questions'] as List?)
                            ?.map((e) => e.toString())
                            .toList() ?? const [],
      isOnlineMode:   (json['mode'] as String?) == 'online',
      intent:         json['intent']?.toString(),
      audioBase64:    json['audio_base64']?.toString(),
      confidence:     (json['confidence'] as num?)?.toDouble() ?? 0.8,
    );
  }

  /// Build from a backend /chatbot/chat or /chatbot/simple-chat response body.
  ///
  /// Field priority for the reply text:
  ///   1. assistant_message  ← standard ChatResponse field
  ///   2. reply              ← SimpleChatResponse field
  ///   3. message            ← legacy / fallback
  ///   4. response           ← very old schema fallback
  factory ChatMessageModel.fromBackendResponse(Map<String, dynamic> data) {
    // Extract the reply text — try each field in priority order
    String responseText = 'I received your message.';
    final am = data['assistant_message']?.toString() ?? '';
    final rp = data['reply']?.toString() ?? '';
    final ms = data['message']?.toString() ?? '';
    final rs = data['response']?.toString() ?? '';

    if (am.isNotEmpty) {
      responseText = am;
    } else if (rp.isNotEmpty) {
      responseText = rp;
    } else if (ms.isNotEmpty) {
      responseText = ms;
    } else if (rs.isNotEmpty) {
      responseText = rs;
    }

    // Parse timestamp if provided by the backend
    DateTime createdAt = DateTime.now();
    final ts = data['timestamp']?.toString();
    if (ts != null && ts.isNotEmpty) {
      createdAt = DateTime.tryParse(ts) ?? DateTime.now();
    }

    return ChatMessageModel(
      id:            'bot-${DateTime.now().millisecondsSinceEpoch}',
      text:          responseText,
      sender:        ChatSender.bot,
      createdAt:     createdAt,
      isEmergency:   data['emergency_detected'] as bool? ?? false,
      followUpQuestions: (data['follow_up_questions'] as List?)
                             ?.map((e) => e.toString())
                             .toList() ??
                         const [],
      // Mark as online whenever the server returned a real AI response
      isOnlineMode:  true,
      intent:        data['intent']?.toString(),
      audioBase64:   data['audio_base64']?.toString(),
      confidence:    (data['confidence'] as num?)?.toDouble() ?? 0.85,
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id':                 id,
    'text':               text,
    'sender':             sender.name,
    'createdAt':          createdAt.toIso8601String(),
    'isVoiceMessage':     isVoiceMessage,
    'is_emergency':       isEmergency,
    'follow_up_questions': followUpQuestions,
    'mode':               isOnlineMode ? 'online' : 'offline',
    'intent':             intent,
    'confidence':         confidence,
  };

  // ── copyWith ──────────────────────────────────────────────────────────────

  ChatMessageModel copyWith({
    String?        id,
    String?        text,
    ChatSender?    sender,
    DateTime?      createdAt,
    bool?          isVoiceMessage,
    bool?          isEmergency,
    List<String>?  followUpQuestions,
    bool?          isOnlineMode,
    String?        intent,
    String?        audioBase64,
    double?        confidence,
  }) {
    return ChatMessageModel(
      id:                id                ?? this.id,
      text:              text               ?? this.text,
      sender:            sender             ?? this.sender,
      createdAt:         createdAt          ?? this.createdAt,
      isVoiceMessage:    isVoiceMessage     ?? this.isVoiceMessage,
      isEmergency:       isEmergency        ?? this.isEmergency,
      followUpQuestions: followUpQuestions  ?? this.followUpQuestions,
      isOnlineMode:      isOnlineMode       ?? this.isOnlineMode,
      intent:            intent             ?? this.intent,
      audioBase64:       audioBase64        ?? this.audioBase64,
      confidence:        confidence         ?? this.confidence,
    );
  }
}
