import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/history/history_card.dart';
import 'chat_history_page.dart';
import 'chat_page.dart';
import 'chatbot_settings_page.dart';
import 'voice_chat_page.dart';

class ChatbotHomePage extends ConsumerStatefulWidget {
  const ChatbotHomePage({super.key});

  @override
  ConsumerState<ChatbotHomePage> createState() => _ChatbotHomePageState();
}

class _ChatbotHomePageState extends ConsumerState<ChatbotHomePage>
    with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatbotControllerProvider);
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DesignTokens.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero banner ────────────────────────────────────────────
                FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: const _HeroBanner(),
                  ),
                ),

                // ── Language quick switch ──────────────────────────────────
                const _LanguageBar(),
                const SizedBox(height: 4),

                // ── Main action cards ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BigCard(
                          emoji: '💬',
                          title: 'Text\nChat',
                          subtitle: 'Type in any language 🌍',
                          colors: DesignTokens.purpleGradient,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ChatPage())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigCard(
                          emoji: '🎙️',
                          title: 'Voice\nChat',
                          subtitle: 'Like Alexa & Siri 🤖',
                          colors: DesignTokens.aquaGradient,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const VoiceChatPage())),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── Features strip ─────────────────────────────────────────
                const _FeaturesStrip(),
                const SizedBox(height: 22),

                // ── Quick starters ─────────────────────────────────────────
                const _SectionHeader(emoji: '💡', title: 'Quick starters'),
                const _QuickStarterGrid(),
                const SizedBox(height: 22),

                // ── Capabilities ───────────────────────────────────────────
                const _SectionHeader(emoji: '✨', title: 'What I can help with'),
                const _CapabilitiesWrap(),
                const SizedBox(height: 22),

                // ── Recent chats ───────────────────────────────────────────
                _SectionHeader(
                  emoji: '🗂️',
                  title: 'Recent Chats',
                  trailing: state.history.isNotEmpty
                      ? _ViewAllBtn(onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ChatHistoryPage())))
                      : null,
                ),
                if (state.history.isEmpty)
                  const _EmptyHistory()
                else
                  for (final c in state.history.take(3))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: HistoryCard(conversation: c),
                    ),

                const SizedBox(height: 8),

                // ── Disclaimer ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DesignTokens.warningContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: DesignTokens.warning.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('⚠️', style: TextStyle(fontSize: 15)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This AI provides general health information only. '
                            'Always consult a qualified doctor for medical advice. 🩺',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF92400E), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: DesignTokens.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Row(
        children: [
          Text('🤖', style: TextStyle(fontSize: 22)),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Medical Assistant',
                  style: TextStyle(color: DesignTokens.textStrong,
                      fontSize: 16, fontWeight: FontWeight.w800)),
              Text('Alexa-style • 4 Languages 🌍',
                  style: TextStyle(color: DesignTokens.textMuted,
                      fontSize: 10, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: DesignTokens.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: DesignTokens.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.settings_outlined,
                color: DesignTokens.primaryDark, size: 18),
          ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChatbotSettingsPage())),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: DesignTokens.border),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero banner — gradient card with bot avatar
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B47E8), Color(0xFF4F94FF), Color(0xFF18C8C8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B47E8).withValues(alpha: 0.38),
            blurRadius: 26, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌍', style: TextStyle(fontSize: 11)),
                      SizedBox(width: 4),
                      Text('English • हिंदी • नेपाली • भोजपुरी',
                          style: TextStyle(color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your Personal\nHealth Assistant 🩺',
                  style: TextStyle(color: Colors.white, fontSize: 21,
                      fontWeight: FontWeight.w900, height: 1.15, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ask about symptoms 🤒, medicines 💊,\n'
                  'nutrition 🥗 or any health question.',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 6, runSpacing: 4,
                  children: [
                    _Pill('🎙️ Voice'), _Pill('💬 Chat'),
                    _Pill('📴 Offline'), _Pill('🚨 Emergency'),
                    _Pill('🌍 4 Languages'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 58)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('AI Doctor',
                    style: TextStyle(color: Colors.white, fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 10,
                fontWeight: FontWeight.w600)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Language bar
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageBar extends ConsumerWidget {
  const _LanguageBar();

  static const _langs = [
    ('en', '🇬🇧', 'EN'), ('hi', '🇮🇳', 'HI'),
    ('ne', '🇳🇵', 'NE'), ('bho', '🗣️', 'BHO'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatbotControllerProvider);
    final ctrl  = ref.read(chatbotControllerProvider.notifier);
    final sel   = state.selectedLanguage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          const Text('🌐', style: TextStyle(fontSize: 14, color: DesignTokens.textMuted)),
          const SizedBox(width: 8),
          const Text('Language:',
              style: TextStyle(fontSize: 12, color: DesignTokens.textMuted,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          ..._langs.map((l) => GestureDetector(
                onTap: () => ctrl.updateLanguageCode(l.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel == l.$1
                        ? DesignTokens.primary.withValues(alpha: 0.12)
                        : DesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sel == l.$1 ? DesignTokens.primary : DesignTokens.border,
                      width: sel == l.$1 ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.$2, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 3),
                      Text(l.$3,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: sel == l.$1 ? FontWeight.w800 : FontWeight.w500,
                            color: sel == l.$1
                                ? DesignTokens.primaryDark
                                : DesignTokens.textMuted,
                          )),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Big action cards
// ─────────────────────────────────────────────────────────────────────────────

class _BigCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final List<Color> colors;
  final VoidCallback onTap;
  const _BigCard({
    required this.emoji, required this.title, required this.subtitle,
    required this.colors, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.38),
                blurRadius: 18, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w900, height: 1.15)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tap to start',
                        style: TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Features strip — horizontal scroll
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturesStrip extends StatelessWidget {
  const _FeaturesStrip();

  static const _features = [
    ('🎙️', 'Voice Chat',   Color(0xFF926EFF), Color(0xFFF0EBFF)),
    ('💬', 'Text Chat',    Color(0xFF4F94FF), Color(0xFFE8F1FF)),
    ('🌍', '4 Languages',  Color(0xFF2ECC8B), Color(0xFFE4FBF0)),
    ('📴', 'Works Offline',Color(0xFFFFB829), Color(0xFFFFF8E6)),
    ('🚨', 'Emergency',    Color(0xFFFF4757), Color(0xFFFFECED)),
    ('🧠', 'AI Powered',   Color(0xFF926EFF), Color(0xFFF0EBFF)),
    ('🩺', 'Medical Info', Color(0xFF18C8C8), Color(0xFFE4FAFA)),
    ('🔊', 'Speaks Back',  Color(0xFFFF7B3D), Color(0xFFFFF0E8)),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _features.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final f = _features[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: f.$4,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: f.$3.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(f.$1, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(f.$2,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: f.$3)),
                ],
              ),
            );
          },
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick starter grid
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStarterGrid extends ConsumerWidget {
  const _QuickStarterGrid();

  static const _starters = [
    ('🌡️', 'I have fever and cough',      Color(0xFFFF4757), Color(0xFFFFECED)),
    ('🤕', 'I have a headache',            Color(0xFFFF7B3D), Color(0xFFFFF0E8)),
    ('💊', 'What is Paracetamol?',          Color(0xFF4F94FF), Color(0xFFE8F1FF)),
    ('🥗', 'Foods for diabetes',            Color(0xFF2ECC8B), Color(0xFFE4FBF0)),
    ('🤰', 'Pregnancy nutrition tips',      Color(0xFFFF5E9E), Color(0xFFFFEAF3)),
    ('👶', 'Child vaccination info',        Color(0xFF18C8C8), Color(0xFFE4FAFA)),
    ('🚨', 'Heart attack symptoms',         Color(0xFFFF4757), Color(0xFFFFECED)),
    ('🧠', 'I feel stressed and anxious',   Color(0xFF926EFF), Color(0xFFF0EBFF)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(chatbotControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10,
          mainAxisSpacing: 10, childAspectRatio: 2.6,
        ),
        itemCount: _starters.length,
        itemBuilder: (_, i) {
          final s = _starters[i];
          return GestureDetector(
            onTap: () {
              ctrl.sendMessage(s.$2);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatPage()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: s.$4,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: s.$3.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Text(s.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.$2,
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700,
                            color: s.$3, height: 1.2),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Capabilities wrap
// ─────────────────────────────────────────────────────────────────────────────

class _CapabilitiesWrap extends StatelessWidget {
  const _CapabilitiesWrap();

  static const _caps = [
    ('🩺', 'Symptoms',   Color(0xFF926EFF), Color(0xFFF0EBFF)),
    ('💊', 'Medicines',  Color(0xFF4F94FF), Color(0xFFE8F1FF)),
    ('🍎', 'Nutrition',  Color(0xFF2ECC8B), Color(0xFFE4FBF0)),
    ('🏃', 'Exercise',   Color(0xFFFFB829), Color(0xFFFFF8E6)),
    ('🤰', 'Pregnancy',  Color(0xFFFF5E9E), Color(0xFFFFEAF3)),
    ('👶', 'Child Care', Color(0xFF18C8C8), Color(0xFFE4FAFA)),
    ('👴', 'Elderly',    Color(0xFFBF8B5E), Color(0xFFF9EDE0)),
    ('🚨', 'Emergency',  Color(0xFFFF4757), Color(0xFFFFECED)),
    ('🧠', 'Mental',     Color(0xFF926EFF), Color(0xFFF0EBFF)),
    ('💉', 'Vaccines',   Color(0xFF5F6FFF), Color(0xFFEEEFFF)),
    ('🦷', 'Dental',     Color(0xFF2ECC8B), Color(0xFFE4FBF0)),
    ('👁️', 'Eye Care',   Color(0xFF4F94FF), Color(0xFFE8F1FF)),
  ];

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8, runSpacing: 8,
          children: _caps.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: c.$4,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.$3.withValues(alpha: 0.3), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.$1, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(c.$2,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: c.$3)),
                  ],
                ),
              )).toList(),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String emoji, title;
  final Widget? trailing;
  const _SectionHeader({required this.emoji, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong, letterSpacing: -0.3)),
            ]),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class _ViewAllBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewAllBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: DesignTokens.purpleGradient,
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text('View all →',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: DesignTokens.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DesignTokens.primary.withValues(alpha: 0.2)),
          ),
          child: const Column(
            children: [
              Text('💬', style: TextStyle(fontSize: 36)),
              SizedBox(height: 10),
              Text('No conversations yet',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                      color: DesignTokens.primaryDark)),
              SizedBox(height: 4),
              Text('Start chatting to see your history here 📝',
                  style: TextStyle(color: DesignTokens.primaryDark, fontSize: 13),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
