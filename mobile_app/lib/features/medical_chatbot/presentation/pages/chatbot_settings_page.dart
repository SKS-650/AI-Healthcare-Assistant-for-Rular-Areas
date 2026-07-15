import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../data/datasources/chatbot_dummy_data.dart';
import '../../data/models/chatbot_settings_model.dart';
import '../../domain/entities/language.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/language/language_selector.dart';
import '../widgets/settings/font_size_selector.dart';
import '../widgets/settings/voice_speed_slider.dart';

class ChatbotSettingsPage extends ConsumerWidget {
  const ChatbotSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state      = ref.watch(chatbotControllerProvider);
    final controller = ref.read(chatbotControllerProvider.notifier);

    // Always use a safe settings object — never null
    final settings = state.settings ?? ChatbotDummyData.settings;

    // Ensure language is always one that exists in Language.all
    final safeLanguage = Language.fromCode(settings.language.code);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: _SettingsAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Language ────────────────────────────────────────────────────
          _SectionCard(
            emoji: '🌍',
            title: 'Language',
            subtitle: 'Choose your preferred language',
            child: LanguageSelector(
              // Use Language.all so ALL 8 codes are always in the list —
              // fixes the DropdownButton assertion about 'bho' not found.
              selectedLanguage: safeLanguage,
              languages:        Language.all,
              onChanged:        controller.updateLanguage,
            ),
          ),

          const SizedBox(height: 16),

          // ── Voice ────────────────────────────────────────────────────────
          _SectionCard(
            emoji: '🔊',
            title: 'Voice',
            subtitle: 'Text-to-speech settings',
            child: Column(
              children: [
                _ToggleTile(
                  emoji:    '🗣️',
                  title:    'Voice responses',
                  subtitle: 'AI replies will be read aloud',
                  value:    settings.voiceResponsesEnabled,
                  onChanged: (v) => controller.updateSettings(
                    ChatbotSettingsModel.fromEntity(settings)
                        .copyWith(voiceResponsesEnabled: v),
                  ),
                ),
                const _Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Voice speed',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: DesignTokens.textStrong,
                              ),
                            ),
                            Text(
                              '${settings.voiceSpeed.toStringAsFixed(1)}x speed',
                              style: const TextStyle(
                                color: DesignTokens.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: VoiceSpeedSlider(
                          value: settings.voiceSpeed,
                          onChanged: (v) => controller.updateSettings(
                            ChatbotSettingsModel.fromEntity(settings)
                                .copyWith(voiceSpeed: v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Display ──────────────────────────────────────────────────────
          _SectionCard(
            emoji: '✏️',
            title: 'Display',
            subtitle: 'Chat appearance',
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('📝', style: TextStyle(fontSize: 17)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Font size',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: DesignTokens.textStrong,
                          ),
                        ),
                        Text(
                          '${settings.fontSize.toInt()}px',
                          style: const TextStyle(
                            color: DesignTokens.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FontSizeSelector(
                    value: settings.fontSize,
                    onChanged: (v) => controller.updateSettings(
                      ChatbotSettingsModel.fromEntity(settings)
                          .copyWith(fontSize: v),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Privacy ──────────────────────────────────────────────────────
          _SectionCard(
            emoji: '🔒',
            title: 'Privacy',
            subtitle: 'Data and history',
            child: _ToggleTile(
              emoji:    '📝',
              title:    'Save chat history',
              subtitle: 'Keep conversations on this device',
              value:    settings.saveHistory,
              onChanged: (v) => controller.updateSettings(
                ChatbotSettingsModel.fromEntity(settings)
                    .copyWith(saveHistory: v),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Info banner ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DesignTokens.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: DesignTokens.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ℹ️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All data is stored locally on your device. '
                    'Nothing is shared without your permission.',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.primaryDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DesignTokens.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: DesignTokens.textStrong,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        children: [
          Text('⚙️', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text(
            'Chatbot Settings',
            style: TextStyle(
              color: DesignTokens.textStrong,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: DesignTokens.border),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.textStrong,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: DesignTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: DesignTokens.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Tiles
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: value
                  ? DesignTokens.primaryContainer
                  : DesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 17)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: DesignTokens.textStrong,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: DesignTokens.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: DesignTokens.primary,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: DesignTokens.border);
}
