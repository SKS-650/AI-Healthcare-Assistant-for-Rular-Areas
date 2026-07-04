import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../data/datasources/chatbot_dummy_data.dart';
import '../../data/models/chatbot_settings_model.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/language/language_selector.dart';
import '../widgets/settings/font_size_selector.dart';
import '../widgets/settings/voice_speed_slider.dart';

class ChatbotSettingsPage extends ConsumerWidget {
  const ChatbotSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatbotControllerProvider);
    final settings = state.settings ?? ChatbotDummyData.settings;
    final controller = ref.read(chatbotControllerProvider.notifier);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        elevation: 0,
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
            Text('âš™ï¸', style: TextStyle(fontSize: 18)),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Language section
          _SectionHeader(emoji: 'ðŸŒ', title: 'Language'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: DesignTokens.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DesignTokens.border),
            ),
            padding: const EdgeInsets.all(12),
            child: LanguageSelector(
              selectedLanguage: settings.language,
              languages: ChatbotDummyData.languages,
              onChanged: controller.updateLanguage,
            ),
          ),

          const SizedBox(height: 24),

          // Voice section
          _SectionHeader(emoji: 'ðŸ”Š', title: 'Voice'),
          const SizedBox(height: 8),
          _SettingCard(
            children: [
              _ToggleTile(
                emoji: 'ðŸ—£ï¸',
                title: 'Voice responses',
                subtitle: 'Read AI replies aloud',
                value: settings.voiceResponsesEnabled,
                onChanged: (v) => controller.updateSettings(
                  ChatbotSettingsModel.fromEntity(settings).copyWith(voiceResponsesEnabled: v),
                ),
              ),
              const _Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const Text('âš¡', style: TextStyle(fontSize: 16)),
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
                      width: 140,
                      child: VoiceSpeedSlider(
                        value: settings.voiceSpeed,
                        onChanged: (v) => controller.updateSettings(
                          ChatbotSettingsModel.fromEntity(settings).copyWith(voiceSpeed: v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Display section
          _SectionHeader(emoji: 'ðŸ–‹ï¸', title: 'Display'),
          const SizedBox(height: 8),
          _SettingCard(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const Text('ðŸ”¤', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
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
                            '${settings.fontSize.toStringAsFixed(0)}px',
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
                        ChatbotSettingsModel.fromEntity(settings).copyWith(fontSize: v),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Privacy section
          _SectionHeader(emoji: 'ðŸ”’', title: 'Privacy'),
          const SizedBox(height: 8),
          _SettingCard(
            children: [
              _ToggleTile(
                emoji: 'ðŸ“',
                title: 'Save chat history',
                subtitle: 'Keep conversations on this device',
                value: settings.saveHistory,
                onChanged: (v) => controller.updateSettings(
                  ChatbotSettingsModel.fromEntity(settings).copyWith(saveHistory: v),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Info note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DesignTokens.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Text('â„¹ï¸', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All data is stored locally on your device. Nothing is shared without your permission.',
                    style: TextStyle(
                      color: DesignTokens.primaryDark,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;

  const _SectionHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textStrong,
          ),
        ),
      ],
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Column(children: children),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
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
                  style: const TextStyle(color: DesignTokens.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: DesignTokens.primary,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: DesignTokens.borderMuted, indent: 16, endIndent: 16);
  }
}
