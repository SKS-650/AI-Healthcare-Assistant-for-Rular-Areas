import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../data/models/chatbot_settings_model.dart';
import '../../../domain/entities/voice_type.dart';
import '../../providers/chatbot_provider.dart';

/// Voice type selector with preview capability.
/// 
/// Displays 5 voice options in a grid with visual feedback
/// and ability to test each voice before selecting.
class VoiceTypeSelector extends ConsumerStatefulWidget {
  final VoiceType selectedVoiceType;
  final ValueChanged<VoiceType> onChanged;

  const VoiceTypeSelector({
    super.key,
    required this.selectedVoiceType,
    required this.onChanged,
  });

  @override
  ConsumerState<VoiceTypeSelector> createState() => _VoiceTypeSelectorState();
}

class _VoiceTypeSelectorState extends ConsumerState<VoiceTypeSelector> {
  VoiceType? _previewingVoice;

  /// Preview sample text for each language
  String _getPreviewText(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Hello! I am your healthcare assistant. How can I help you today?';
      case 'hi':
        return 'नमस्ते! मैं आपका स्वास्थ्य सहायक हूं। आज मैं आपकी कैसे मदद कर सकता हूं?';
      case 'ne':
        return 'नमस्ते! म तपाईंको स्वास्थ्य सहायक हुँ। आज म तपाईंलाई कसरी मद्दत गर्न सक्छु?';
      case 'bho':
        return 'नमस्कार! हम रउआ के स्वास्थ्य सहायक हईं। आज हम रउआ के कइसे मदद कर सकत हईं?';
      default:
        return 'Hello! I am your healthcare assistant.';
    }
  }

  Future<void> _previewVoice(VoiceType voiceType) async {
    final controller = ref.read(chatbotControllerProvider.notifier);
    final state = ref.read(chatbotControllerProvider);
    final languageCode = state.selectedLanguage;

    setState(() {
      _previewingVoice = voiceType;
    });

    // Get preview text in current language
    final previewText = _getPreviewText(languageCode);

    // Temporarily speak with this voice type
    // We'll use the controller's speakText but need to temporarily update settings
    final currentSettings = state.settings;
    if (currentSettings != null) {
      // Save current voice type
      final originalVoiceType = currentSettings.voiceType;
      
      // Temporarily set the preview voice type
      await controller.updateSettings(
        ChatbotSettingsModel.fromEntity(currentSettings)
            .copyWith(voiceType: voiceType),
      );
      
      // Speak the preview
      await controller.speakText(previewText, language: languageCode);
      
      // Wait a bit before allowing the next preview
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Restore original voice type if user didn't select this one
      if (widget.selectedVoiceType != voiceType) {
        await controller.updateSettings(
          ChatbotSettingsModel.fromEntity(currentSettings)
              .copyWith(voiceType: originalVoiceType),
        );
      }
    }

    if (mounted) {
      setState(() {
        _previewingVoice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(
      chatbotControllerProvider.select((s) => s.voiceState),
    );
    final isSpeaking = voiceState.isSpeaking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info text
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              const Text('🎭', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Choose a voice that suits you. Tap the play button to preview.',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textMuted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Voice options grid
        ...VoiceType.values.map((voiceType) {
          final isSelected = widget.selectedVoiceType == voiceType;
          final isPreviewing = _previewingVoice == voiceType;
          final isDisabled = isSpeaking && !isPreviewing;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _VoiceCard(
              voiceType: voiceType,
              isSelected: isSelected,
              isPreviewing: isPreviewing,
              isDisabled: isDisabled,
              onSelect: () => widget.onChanged(voiceType),
              onPreview: () => _previewVoice(voiceType),
            ),
          );
        }).toList(),

        // Speaker indicator
        if (isSpeaking)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: DesignTokens.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DesignTokens.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DesignTokens.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Playing preview...',
                    style: TextStyle(
                      fontSize: 11,
                      color: DesignTokens.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Voice Card
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceCard extends StatelessWidget {
  final VoiceType voiceType;
  final bool isSelected;
  final bool isPreviewing;
  final bool isDisabled;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const _VoiceCard({
    required this.voiceType,
    required this.isSelected,
    required this.isPreviewing,
    required this.isDisabled,
    required this.onSelect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? DesignTokens.primaryContainer
                : DesignTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? DesignTokens.primary
                  : DesignTokens.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Emoji icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignTokens.primary.withValues(alpha: 0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    voiceType.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Voice info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voiceType.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? DesignTokens.primary
                            : DesignTokens.textStrong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      voiceType.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: DesignTokens.textMuted,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Pitch indicator
                    Row(
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          size: 12,
                          color: DesignTokens.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pitch: ${voiceType.pitch.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: DesignTokens.textMuted,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Preview button
              IconButton(
                icon: Icon(
                  isPreviewing ? Icons.stop_circle : Icons.play_circle_outline,
                  color: isDisabled
                      ? DesignTokens.textMuted.withValues(alpha: 0.3)
                      : DesignTokens.primary,
                ),
                onPressed: isDisabled ? null : onPreview,
                tooltip: 'Preview voice',
              ),

              // Selected indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: DesignTokens.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
