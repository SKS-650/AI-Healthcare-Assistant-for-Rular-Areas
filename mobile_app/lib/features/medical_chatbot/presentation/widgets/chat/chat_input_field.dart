import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

/// Bottom chat input matching screenshot:
/// [mic btn] [ text field ] [emoji btn] | [send/voice btn]
class ChatInputField extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onSend;
  final VoidCallback? onVoice;

  const ChatInputField({
    super.key,
    required this.enabled,
    required this.onSend,
    this.onVoice,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _hasText = false;
  int  _hintIdx = 0;

  // 4-language rotating hints
  static const _hints = [
    '💬 Ask me anything… (English)',
    '💬 कुछ भी पूछें… (हिंदी)',
    '💬 केहि पनि सोध्नुहोस्… (नेपाली)',
    '💬 कुछ भी पूछा… (भोजपुरी)',
  ];

  late final AnimationController _hintAnim;
  late final Animation<double>   _hintFade;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _hintAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _hintFade = CurvedAnimation(parent: _hintAnim, curve: Curves.easeInOut);
    _hintAnim.value = 1.0;

    // Rotate hint every 3 s when empty
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      if (_hasText) return true;
      await _hintAnim.reverse();
      if (!mounted) return false;
      setState(() => _hintIdx = (_hintIdx + 1) % _hints.length);
      await _hintAnim.forward();
      return true;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _hintAnim.dispose();
    super.dispose();
  }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty || !widget.enabled) return;
    widget.onSend(t);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurface : DesignTokens.surface,
        border: const Border(top: BorderSide(color: DesignTokens.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10, offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Text + mic + emoji row ────────────────────────────────────
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark ? DesignTokens.darkSurfaceMuted : DesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _hasText
                        ? DesignTokens.primary.withValues(alpha: 0.55)
                        : DesignTokens.border,
                    width: _hasText ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Mic inside field (shortcut to voice)
                    Padding(
                      padding: const EdgeInsets.only(left: 5, bottom: 7),
                      child: _CircleBtn(
                        icon: Icons.mic_outlined,
                        onTap: (widget.enabled && widget.onVoice != null)
                            ? widget.onVoice
                            : null,
                        color: DesignTokens.primary,
                        bgColor: DesignTokens.primaryContainer,
                        size: 32,
                      ),
                    ),

                    // Text area with animated hint
                    Expanded(
                      child: Stack(
                        children: [
                          if (!_hasText)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: FadeTransition(
                                    opacity: _hintFade,
                                    child: Text(
                                      _hints[_hintIdx],
                                      style: const TextStyle(
                                          color: DesignTokens.textSubtle, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          TextField(
                            controller: _ctrl,
                            enabled: widget.enabled,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isDark
                                  ? DesignTokens.darkTextStrong
                                  : DesignTokens.textStrong,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: null,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ],
                      ),
                    ),

                    // Emoji picker button
                    Padding(
                      padding: const EdgeInsets.only(right: 5, bottom: 7),
                      child: _CircleBtn(
                        icon: Icons.emoji_emotions_outlined,
                        onTap: widget.enabled ? () => _showEmojiPicker(context) : null,
                        color: DesignTokens.warning,
                        bgColor: DesignTokens.warningContainer,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ── Send / voice big button ───────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: _hasText
                  ? _CircleBtn(
                      key: const ValueKey('send'),
                      icon: Icons.send_rounded,
                      onTap: widget.enabled ? _send : null,
                      color: Colors.white,
                      bgColor: DesignTokens.primary,
                      size: 46,
                      gradient: DesignTokens.purpleGradient,
                    )
                  : _CircleBtn(
                      key: const ValueKey('voice'),
                      icon: Icons.mic_rounded,
                      onTap: (widget.enabled && widget.onVoice != null)
                          ? widget.onVoice
                          : null,
                      color: Colors.white,
                      bgColor: DesignTokens.aqua,
                      size: 46,
                      gradient: DesignTokens.aquaGradient,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(BuildContext ctx) {
    const emojis = [
      '😊', '😷', '🤒', '🤕', '💊', '🌡️', '🏥', '🩺', '💉',
      '🥗', '🏃', '🤰', '👶', '🚨', '🧠', '❤️', '🍎', '💧',
      '😴', '🤧', '🤢', '😰', '💪', '🫁', '🦷', '👁️', '🫀',
    ];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: DesignTokens.border, borderRadius: BorderRadius.circular(2)),
            ),
            const Text('😊 Quick Emoji',
                style: TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 14, color: DesignTokens.textStrong)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: emojis.map((e) => GestureDetector(
                    onTap: () {
                      _ctrl.text += e;
                      _ctrl.selection = TextSelection.collapsed(
                          offset: _ctrl.text.length);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(e, style: const TextStyle(fontSize: 24))),
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable circle button
// ─────────────────────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color, bgColor;
  final double size;
  final List<Color>? gradient;

  const _CircleBtn({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
    required this.bgColor,
    this.size = 40,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient != null
                ? LinearGradient(
                    colors: onTap != null
                        ? gradient!
                        : [Colors.grey.shade300, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: gradient == null
                ? (onTap != null ? bgColor : Colors.grey.shade200)
                : null,
            boxShadow: onTap != null && gradient != null
                ? [
                    BoxShadow(
                      color: gradient!.first.withValues(alpha: 0.35),
                      blurRadius: 8, offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon,
              color: onTap != null ? color : Colors.grey.shade400,
              size: size * 0.44),
        ),
      );
}
