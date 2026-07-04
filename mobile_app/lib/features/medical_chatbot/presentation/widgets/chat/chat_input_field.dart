import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class ChatInputField extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onSend;

  const ChatInputField({
    super.key,
    required this.enabled,
    required this.onSend,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurface : DesignTokens.surface,
        border: Border(
          top: BorderSide(color: DesignTokens.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            _CircleButton(
              icon: Icons.add_rounded,
              onTap: widget.enabled ? () {} : null,
              color: DesignTokens.textMuted,
              bgColor: isDark
                  ? DesignTokens.darkSurfaceMuted
                  : DesignTokens.surfaceMuted,
            ),
            const SizedBox(width: 8),
            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignTokens.darkSurfaceMuted
                      : DesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? DesignTokens.darkBorder : DesignTokens.border,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: widget.enabled,
                        textInputAction: TextInputAction.send,
                        minLines: 1,
                        maxLines: 5,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DesignTokens.textStrong,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Describe your symptoms...',
                          hintStyle: TextStyle(
                            color: DesignTokens.textSubtle,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: widget.enabled ? (_) => _send() : null,
                      ),
                    ),
                    // Mic button inside text field
                    Padding(
                      padding: const EdgeInsets.only(right: 6, bottom: 6),
                      child: _CircleButton(
                        icon: Icons.mic_outlined,
                        onTap: widget.enabled ? () {} : null,
                        color: DesignTokens.textMuted,
                        bgColor: Colors.transparent,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _hasText && widget.enabled
                    ? const LinearGradient(
                        colors: [DesignTokens.primary, DesignTokens.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !_hasText || !widget.enabled
                    ? DesignTokens.surfaceMuted
                    : null,
                shape: BoxShape.circle,
                boxShadow: _hasText && widget.enabled
                    ? [
                        BoxShadow(
                          color: DesignTokens.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: (_hasText && widget.enabled) ? _send : null,
                  child: Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: _hasText && widget.enabled
                        ? Colors.white
                        : DesignTokens.textSubtle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color bgColor;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.bgColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bgColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, size: size * 0.45, color: color),
        ),
      ),
    );
  }
}
