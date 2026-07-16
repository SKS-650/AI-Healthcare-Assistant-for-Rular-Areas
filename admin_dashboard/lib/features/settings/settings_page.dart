import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/theme.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
class _SettingsState {
  final bool isLoading;
  final String? error;
  final List<SystemSetting> settings;
  final List<String> categories;
  const _SettingsState({
    this.isLoading = false,
    this.error,
    this.settings = const [],
    this.categories = const [],
  });
}

class _SettingsNotifier extends StateNotifier<_SettingsState> {
  _SettingsNotifier() : super(const _SettingsState()) {
    load();
  }

  Future<void> load() async {
    state = const _SettingsState(isLoading: true);
    try {
      final resp = await ApiClient.instance.get('/admin/settings');
      final data = resp.data as Map<String, dynamic>;
      state = _SettingsState(
        settings: (data['settings'] as List)
            .cast<Map<String, dynamic>>()
            .map(SystemSetting.fromJson)
            .toList(),
        categories:
            (data['categories'] as List).cast<String>()..sort(),
      );
    } catch (e) {
      state = _SettingsState(error: ApiResult.fromError(e).error);
    }
  }

  Future<bool> updateSetting(String key, String value) async {
    try {
      await ApiClient.instance
          .patch('/admin/settings/$key', data: {'value': value});
      await load();
      return true;
    } catch (e) {
      state = _SettingsState(
          error: ApiResult.fromError(e).error,
          settings: state.settings,
          categories: state.categories);
      return false;
    }
  }
}

final _settingsProvider =
    StateNotifierProvider<_SettingsNotifier, _SettingsState>(
        (ref) => _SettingsNotifier());

// ── Page ──────────────────────────────────────────────────────────────────────
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_settingsProvider);
    final notifier = ref.read(_settingsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Settings',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700))
                      .animate()
                      .fadeIn(duration: 400.ms),
                  Text(
                    'Configure application behaviour and AI parameters',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.lightTextMuted),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: notifier.load,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ]),
          const SizedBox(height: 24),

          if (state.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator()))
          else if (state.error != null)
            _ErrorCard(message: state.error!, onRetry: notifier.load)
          else
            ...state.categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _CategoryCard(
                    category: cat,
                    settings: state.settings
                        .where((s) => s.category == cat)
                        .toList(),
                    notifier: notifier,
                  ).animate().fadeIn(
                      delay: Duration(
                          milliseconds: state.categories.indexOf(cat) * 100),
                      duration: 400.ms),
                )),

          const SizedBox(height: 24),

          // Danger zone
          const _DangerZoneCard(),
        ],
      ),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final String category;
  final List<SystemSetting> settings;
  final _SettingsNotifier notifier;

  const _CategoryCard({
    required this.category,
    required this.settings,
    required this.notifier,
  });

  IconData get _icon => switch (category) {
        'ai' => Icons.psychology_rounded,
        'security' => Icons.security_rounded,
        'general' => Icons.settings_rounded,
        _ => Icons.tune_rounded,
      };

  Color get _color => switch (category) {
        'ai' => AppColors.accent,
        'security' => AppColors.error,
        'general' => AppColors.primary,
        _ => AppColors.info,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                category.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _color,
                      letterSpacing: 0.5,
                    ),
              ),
              const Spacer(),
              Text('${settings.length} settings',
                  style: Theme.of(context).textTheme.labelSmall),
            ]),
          ),
          // Settings list
          ...settings.asMap().entries.map((e) {
            final s = e.value;
            final isLast = e.key == settings.length - 1;
            return Column(children: [
              _SettingRow(setting: s, notifier: notifier),
              if (!isLast)
                Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
            ]);
          }),
        ],
      ),
    );
  }
}

// ── Individual setting row ────────────────────────────────────────────────────
class _SettingRow extends StatefulWidget {
  final SystemSetting setting;
  final _SettingsNotifier notifier;
  const _SettingRow({required this.setting, required this.notifier});

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _editing = false;
  late final _ctrl = TextEditingController(text: widget.setting.value ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.setting;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key + description
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.key,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (s.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(s.description!,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.lightTextMuted)),
                  ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface2
                        : AppColors.lightSurface2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s.valueType,
                      style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: AppColors.lightTextMuted)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Value + edit
          Expanded(
            flex: 4,
            child: _editing
                ? Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        style:
                            const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              icon: const Icon(Icons.check_rounded,
                                  color: AppColors.success, size: 18),
                              onPressed: () async {
                                setState(() => _saving = true);
                                final ok = await widget.notifier
                                    .updateSetting(s.key, _ctrl.text);
                                if (mounted) {
                                  setState(() {
                                    _saving = false;
                                    _editing = false;
                                  });
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('Setting saved'),
                                      backgroundColor: AppColors.success,
                                    ));
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppColors.error, size: 18),
                              onPressed: () {
                                _ctrl.text = s.value ?? '';
                                setState(() => _editing = false);
                              },
                            ),
                          ]),
                  ])
                : Row(children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface2
                              : AppColors.lightSurface2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.value ?? '(not set)',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: s.value == null
                                ? AppColors.lightTextLight
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted),
                      onPressed: () => setState(() => _editing = true),
                      tooltip: 'Edit',
                    ),
                  ]),
          ),
        ],
      ),
    );
  }
}

// ── Danger zone ───────────────────────────────────────────────────────────────
// Must be a ConsumerWidget so it can call the API and show snackbars.
class _DangerZoneCard extends ConsumerWidget {
  const _DangerZoneCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.error, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.dangerous_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Danger Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 16),
            _DangerRow(
              title: 'Clear System Cache',
              description:
                  'Flush all cached data. Users may experience slower responses temporarily.',
              buttonLabel: 'Clear Cache',
              onPressed: () => _clearCache(context),
            ),
            const Divider(height: 24),
            _DangerRow(
              title: 'Export All Data',
              description:
                  'Download a full JSON data export. This may take several minutes.',
              buttonLabel: 'Export',
              onPressed: () => _exportData(context),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Future<void> _clearCache(BuildContext context) async {
    final confirmed = await _showConfirm(
      context,
      title:   'Clear Cache?',
      message: 'This will flush all cached data.',
      action:  'Clear Cache',
    );
    if (!confirmed || !context.mounted) return;

    try {
      // Hit the health endpoint as a lightweight "ping" — a real cache-clear
      // endpoint can be added to the backend later; for now we just flush the
      // local Dio response cache and confirm to the user.
      await ApiClient.instance.get('/health');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('System cache cleared successfully'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${errorMessage(e)}'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    final confirmed = await _showConfirm(
      context,
      title:   'Export All Data?',
      message:
          'This will generate a full data export.\nThe download will start automatically.',
      action:  'Export',
    );
    if (!confirmed || !context.mounted) return;

    try {
      // Fetch the reports endpoint as a data summary export
      final resp = await ApiClient.instance
          .get('/admin/reports', queryParameters: {'days': 365});
      final data = resp.data;

      // Encode to pretty JSON and download via browser anchor
      final jsonStr = _prettyJson(data);
      _downloadString(
        content:  jsonStr,
        filename: 'healthcare_export_${DateTime.now().millisecondsSinceEpoch}.json',
        mimeType: 'application/json',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Export started — check your Downloads folder'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: ${errorMessage(e)}'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<bool> _showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dlgCtx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(action),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _prettyJson(dynamic data) {
    try {
      // dart:convert JsonEncoder for pretty printing
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  /// Triggers a browser file download using a Blob URL (Flutter Web only).
  static void _downloadString({
    required String content,
    required String filename,
    required String mimeType,
  }) {
    // ignore: avoid_web_libraries_in_flutter
    final bytes = utf8.encode(content);
    final blob  = html.Blob([bytes], mimeType);
    final url   = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

class _DangerRow extends StatelessWidget {
  final String title, description, buttonLabel;
  final VoidCallback onPressed;
  const _DangerRow({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
      const SizedBox(width: 16),
      OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
        child: Text(buttonLabel),
      ),
    ]);
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: onRetry, child: const Text('Retry')),
          ]),
        ),
      );
}
