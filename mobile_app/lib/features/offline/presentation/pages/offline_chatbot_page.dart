import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../application/providers/offline_providers.dart';
import '../../data/models/offline_chat_entry_model.dart';
import '../../data/services/offline_chatbot_engine.dart';
import '../../domain/enums/offline_enums.dart';

class OfflineChatbotPage extends ConsumerStatefulWidget {
  const OfflineChatbotPage({super.key});

  @override
  ConsumerState<OfflineChatbotPage> createState() => _OfflineChatbotPageState();
}

class _OfflineChatbotPageState extends ConsumerState<OfflineChatbotPage> {
  static const _primary = Color(0xFF6C63FF);
  static const _bg      = Color(0xFFF0EFFF);

  final _engine  = const OfflineChatbotEngine();
  final _uuid    = const Uuid();
  final _ctrl    = TextEditingController();
  final _scroll  = ScrollController();

  final List<_ChatMsg> _messages = [];
  bool _typing = false;

  // ── Quick suggestion prompts ──────────────────────────────────────────────
  static const List<String> _suggestions = [
    'I have fever and headache',
    'What to eat for diabetes?',
    'How to manage high blood pressure?',
    'Malaria prevention tips',
    'Emergency first aid guide',
    'Child vaccination schedule',
    'Mental health support',
    'Pregnancy warning signs',
  ];

  @override
  void initState() {
    super.initState();
    _addWelcome();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _addWelcome() {
    _messages.add(const _ChatMsg(
      text: '👋 **Hello! I\'m your Offline Medical Assistant.**\n\n'
          'I\'m running completely offline using a local knowledge base. '
          'I can help with:\n\n'
          '• Fever, cough, headache management\n'
          '• Diabetes & blood pressure guidance\n'
          '• Malaria & infectious disease info\n'
          '• Nutrition & diet advice\n'
          '• Child health & vaccinations\n'
          '• Emergency first aid\n'
          '• Mental health support\n\n'
          'What would you like to know?',
      isBot: true,
    ));
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(text: trimmed, isBot: false));
      _typing = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    // Simulate processing delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final response = _engine.answer(trimmed);

    // Persist offline
    final entry = OfflineChatEntryModel(
      id:          _uuid.v4(),
      userMessage: trimmed,
      botResponse: response.answer,
      source:      ChatbotSource.offlineKnowledgeBase,
      createdAt:   DateTime.now(),
      isSynced:    false,
    );
    await ref.read(offlineRepositoryProvider).saveChatEntry(entry);

    setState(() {
      _messages.add(_ChatMsg(text: response.answer, isBot: true));
      _typing = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Row(children: [
          Text('🤖', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Offline Chatbot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Local Knowledge Base', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ]),
        ]),
      ),
      body: Column(
        children: [
          _buildOfflineBanner(),
          Expanded(child: _buildMessageList()),
          if (_typing) _buildTypingIndicator(),
          _buildSuggestions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
    color: const Color(0xFFFF6F00).withValues(alpha: 0.12),
    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.offline_bolt_rounded, size: 14, color: Color(0xFFE65100)),
      SizedBox(width: 6),
      Text('Running offline — responses from local knowledge base',
          style: TextStyle(fontSize: 11, color: Color(0xFFE65100), fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _buildMessageList() => ListView.builder(
    controller: _scroll,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    itemCount: _messages.length,
    itemBuilder: (ctx, i) => _buildBubble(_messages[i], i),
  );

  Widget _buildBubble(_ChatMsg msg, int index) {
    final isBot = msg.isBot;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                  color: _primary, shape: BoxShape.circle),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : _primary,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(16),
                  topRight:    const Radius.circular(16),
                  bottomLeft:  Radius.circular(isBot ? 4 : 16),
                  bottomRight: Radius.circular(isBot ? 16 : 4),
                ),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                )],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isBot ? Colors.grey.shade800 : Colors.white,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    ).animate(delay: (index * 30).ms).fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypingIndicator() => Padding(
    padding: const EdgeInsets.fromLTRB(22, 0, 14, 4),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
        child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          _dot(0), const SizedBox(width: 3),
          _dot(200), const SizedBox(width: 3),
          _dot(400),
        ]),
      ),
    ]),
  );

  Widget _dot(int delayMs) => Container(
    width: 6, height: 6,
    decoration: BoxDecoration(color: _primary.withValues(alpha: 0.6), shape: BoxShape.circle),
  ).animate(onPlay: (c) => c.repeat()).fadeIn(
    duration: const Duration(milliseconds: 400),
    delay: Duration(milliseconds: delayMs),
  );

  Widget _buildSuggestions() => SizedBox(
    height: 38,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _suggestions.length,
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => _sendMessage(_suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              _suggestions[i],
              style: const TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildInputBar() => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
    ),
    child: SafeArea(
      top: false,
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.send,
            onSubmitted: _sendMessage,
            decoration: InputDecoration(
              hintText: 'Ask a health question…',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF5F5FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _sendMessage(_ctrl.text),
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    ),
  );
}

class _ChatMsg {
  const _ChatMsg({required this.text, required this.isBot});
  final String text;
  final bool   isBot;
}
