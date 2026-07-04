import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _locationEnabled = true;
  bool _saveHistory = true;
  bool _darkMode = false;
  bool _offlineMode = false;
  String _language = 'English';
  String _fontSize = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Row(
          children: [
            Text('⚙️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Preferences
            _SettingsSection(
              emoji: '🎨',
              title: 'Appearance',
              children: [
                _SwitchTile(
                  emoji: '🌙',
                  title: 'Dark Mode',
                  subtitle: 'Enable dark theme',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                _SelectTile(
                  emoji: '🔤',
                  title: 'Text Size',
                  subtitle: _fontSize,
                  onTap: () => _showPicker(
                    context,
                    'Text Size',
                    ['Small', 'Medium', 'Large', 'Extra Large'],
                    _fontSize,
                    (v) => setState(() => _fontSize = v),
                  ),
                ),
              ],
            ),

            _SettingsSection(
              emoji: '🌐',
              title: 'Language',
              children: [
                _SelectTile(
                  emoji: '🗣️',
                  title: 'App Language',
                  subtitle: _language,
                  onTap: () => _showPicker(
                    context,
                    'Select Language',
                    ['English', 'Hindi', 'Nepali', 'Bhojpuri', 'Maithili'],
                    _language,
                    (v) => setState(() => _language = v),
                  ),
                ),
              ],
            ),

            _SettingsSection(
              emoji: '🔔',
              title: 'Notifications',
              children: [
                _SwitchTile(
                  emoji: '🔔',
                  title: 'Push Notifications',
                  subtitle: 'Health alerts and reminders',
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                _SwitchTile(
                  emoji: '💊',
                  title: 'Medicine Reminders',
                  subtitle: 'Daily medication alerts',
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
              ],
            ),

            _SettingsSection(
              emoji: '🔒',
              title: 'Privacy & Data',
              children: [
                _SwitchTile(
                  emoji: '📍',
                  title: 'Location Services',
                  subtitle: 'Find nearby hospitals & pharmacies',
                  value: _locationEnabled,
                  onChanged: (v) => setState(() => _locationEnabled = v),
                ),
                _SwitchTile(
                  emoji: '🗂️',
                  title: 'Save Chat History',
                  subtitle: 'Keep conversation records',
                  value: _saveHistory,
                  onChanged: (v) => setState(() => _saveHistory = v),
                ),
                _TapTile(
                  emoji: '🗑️',
                  title: 'Clear All Data',
                  subtitle: 'Delete all local health data',
                  isDestructive: true,
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),

            _SettingsSection(
              emoji: '📡',
              title: 'Connectivity',
              children: [
                _SwitchTile(
                  emoji: '📴',
                  title: 'Offline Mode',
                  subtitle: 'Work without internet',
                  value: _offlineMode,
                  onChanged: (v) => setState(() => _offlineMode = v),
                ),
              ],
            ),

            _SettingsSection(
              emoji: 'ℹ️',
              title: 'About',
              children: [
                _TapTile(
                  emoji: '📱',
                  title: 'App Version',
                  subtitle: 'v1.0.0',
                  onTap: () {},
                ),
                _TapTile(
                  emoji: '📄',
                  title: 'Privacy Policy',
                  subtitle: 'Read our data policy',
                  onTap: () {},
                ),
                _TapTile(
                  emoji: '📋',
                  title: 'Terms of Service',
                  subtitle: 'User agreement',
                  onTap: () {},
                ),
                _TapTile(
                  emoji: '💬',
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(
    BuildContext context,
    String title,
    List<String> options,
    String current,
    void Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DesignTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DesignTokens.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: DesignTokens.textStrong,
              ),
            ),
          ),
          ...options.map(
            (opt) => ListTile(
              title: Text(opt,
                  style: TextStyle(
                    fontWeight: opt == current
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: opt == current
                        ? DesignTokens.primary
                        : DesignTokens.textStrong,
                  )),
              trailing: opt == current
                  ? const Icon(Icons.check_rounded,
                      color: DesignTokens.primary)
                  : null,
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DesignTokens.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🗑️', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Clear All Data',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong)),
          ],
        ),
        content: const Text(
          'This will delete all local records, chat history, and health data. This action cannot be undone.',
          style: TextStyle(color: DesignTokens.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: DesignTokens.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: DesignTokens.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete All',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String emoji, title;
  final List<Widget> children;
  const _SettingsSection(
      {required this.emoji, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: DesignTokens.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DesignTokens.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: children.asMap().entries.map((e) {
                  return Column(
                    children: [
                      e.value,
                      if (e.key < children.length - 1)
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: DesignTokens.borderMuted,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String emoji, title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: DesignTokens.textStrong)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: DesignTokens.textMuted, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: DesignTokens.primary,
        activeTrackColor: DesignTokens.primaryContainer,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final String emoji, title, subtitle;
  final VoidCallback onTap;

  const _SelectTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: DesignTokens.textStrong)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: DesignTokens.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: DesignTokens.textSubtle, size: 18),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _TapTile extends StatelessWidget {
  final String emoji, title, subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _TapTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: isDestructive ? DesignTokens.danger : DesignTokens.textStrong,
        ),
      ),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: DesignTokens.textMuted, fontSize: 12)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDestructive ? DesignTokens.danger : DesignTokens.textSubtle,
        size: 18,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
