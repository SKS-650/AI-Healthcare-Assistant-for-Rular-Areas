import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'chatbot_provider.dart';

class ChatbotPage extends ConsumerStatefulWidget {
  const ChatbotPage({super.key});
  @override
  ConsumerState<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends ConsumerState<ChatbotPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatbotProvider);
    final notifier = ref.read(chatbotProvider.notifier);
    final stats = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Medical Chatbot',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('Monitor conversations, manage config & review emergency flags',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          OutlinedButton.icon(
            onPressed: () => _showConfigDialog(context, state.config, notifier),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('Config'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () { notifier.loadStats(); notifier.loadConversations(); },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // ── Stats ─────────────────────────────────────────────────────────
        LayoutBuilder(builder: (context, cst) {
          final cols = cst.maxWidth > 900 ? 4 : cst.maxWidth > 600 ? 3 : 2;
          return GridView.count(
            crossAxisCount: cols, crossAxisSpacing: 16,
            mainAxisSpacing: 16, childAspectRatio: 1.6,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(title: 'Total Conversations', value: '${stats.totalConversations}',
                  subtitle: '+${stats.todayConversations} today',
                  icon: Icons.chat_bubble_rounded, color: AppColors.accent, animDelay: 0),
              StatCard(title: 'Active Conversations', value: '${stats.activeConversations}',
                  icon: Icons.chat_bubble_outline_rounded, color: AppColors.success, animDelay: 80),
              StatCard(title: 'Total Messages', value: '${stats.totalMessages}',
                  icon: Icons.message_rounded, color: AppColors.primary, animDelay: 160),
              StatCard(title: 'Emergency Flags', value: '${stats.emergencyMessages}',
                  subtitle: 'Messages flagged urgent',
                  icon: Icons.warning_rounded, color: AppColors.error, animDelay: 240),
            ],
          );
        }).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),

        // ── Language distribution ─────────────────────────────────────────
        if (stats.languageDistribution.isNotEmpty)
          _LanguageDistCard(dist: stats.languageDistribution)
              .animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),

        // ── Conversations table ───────────────────────────────────────────
        DataTableCard(
          title: 'All Conversations',
          isLoading: state.isLoading,
          totalRows: state.total,
          currentPage: state.page,
          pageSize: state.pageSize,
          onPageChanged: notifier.goToPage,
          searchBar: SearchField(
            controller: _searchCtrl,
            hint: 'Search conversations...',
            onChanged: (v) { if (v.isEmpty || v.length >= 2) notifier.setSearch(v); },
          ),
          filters: [
            _LangFilter(value: state.languageFilter, onChanged: notifier.setLanguageFilter),
            _EmergencyFilter(value: state.hasEmergencyFilter, onChanged: notifier.setEmergencyFilter),
          ],
          columns: const [
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Language')),
            DataColumn(label: Text('Messages')),
            DataColumn(label: Text('Emergency')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.conversations.map((c) => DataRow(cells: [
            DataCell(_UserCell(userName: c.userName, userId: c.userId)),
            DataCell(SizedBox(width: 200,
                child: Text(c.title, style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis))),
            DataCell(_LangChip(lang: c.language)),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.message_rounded, size: 12, color: AppColors.lightTextMuted),
              const SizedBox(width: 4),
              Text('${c.messageCount}', style: Theme.of(context).textTheme.bodySmall),
            ])),
            DataCell(c.emergencyCount > 0
                ? _EmergencyCount(count: c.emergencyCount)
                : const Text('—')),
            DataCell(StatusBadge(
                active: c.isActive,
                activeLabel: 'Active',
                inactiveLabel: 'Closed')),
            DataCell(Text(DateFormat('MMM d, HH:mm').format(c.createdAt),
                style: Theme.of(context).textTheme.bodySmall)),
            DataCell(_ConvActions(conv: c, notifier: notifier)),
          ])).toList(),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }

  void _showConfigDialog(BuildContext context,
      Map<String, dynamic>? config, ChatbotNotifier notifier) {
    if (config == null) {
      notifier.loadConfig().then((_) {
        if (context.mounted) {
          final updatedConfig = ref.read(chatbotProvider).config;
          if (updatedConfig != null) {
            showDialog(
              context: context,
              builder: (_) => _ChatbotConfigDialog(
                  config: updatedConfig, notifier: notifier),
            );
          }
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading config...')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _ChatbotConfigDialog(config: config, notifier: notifier),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _LanguageDistCard extends StatelessWidget {
  final Map<String, int> dist;
  const _LanguageDistCard({required this.dist});

  @override
  Widget build(BuildContext context) {
    final total = dist.values.fold(0, (a, b) => a + b);
    final langs = {'en': 'English', 'ne': 'Nepali', 'hi': 'Hindi', 'bh': 'Bhojpuri'};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Language Distribution',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(children: dist.entries.map((e) {
            final idx = dist.keys.toList().indexOf(e.key);
            final pct = total > 0 ? e.value / total : 0.0;
            final color = AppColors.chartPalette[idx % AppColors.chartPalette.length];
            return Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 10, height: 10,
                      decoration: BoxDecoration(color: color,
                          borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text(langs[e.key] ?? e.key.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall),
                ]),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                        value: pct.toDouble(),
                        minHeight: 8,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(color))),
                const SizedBox(height: 4),
                Text('${e.value} (${(pct * 100).toStringAsFixed(0)}%)',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ]),
            ));
          }).toList()),
        ]),
      ),
    );
  }
}

class _UserCell extends StatelessWidget {
  final String? userName;
  final String userId;
  const _UserCell({this.userName, required this.userId});
  @override
  Widget build(BuildContext context) {
    final name = userName ?? 'Unknown';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Row(children: [
      Container(width: 28, height: 28,
          decoration: BoxDecoration(color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(initials,
              style: const TextStyle(color: AppColors.accent,
                  fontWeight: FontWeight.w700, fontSize: 11)))),
      const SizedBox(width: 8),
      Text(name, style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(fontWeight: FontWeight.w500)),
    ]);
  }
}

class _LangChip extends StatelessWidget {
  final String lang;
  const _LangChip({required this.lang});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8)),
        child: Text(lang.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      );
}

class _EmergencyCount extends StatelessWidget {
  final int count;
  const _EmergencyCount({required this.count});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: AppColors.errorSurface,
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.warning_rounded, size: 10, color: AppColors.error),
          const SizedBox(width: 3),
          Text('$count', style: const TextStyle(fontSize: 10,
              fontWeight: FontWeight.w700, color: AppColors.error)),
        ]),
      );
}

class _ConvActions extends StatelessWidget {
  final ChatConversation conv;
  final ChatbotNotifier notifier;
  const _ConvActions({required this.conv, required this.notifier});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Tooltip(
          message: 'Delete conversation',
          child: IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ]);

  Future<void> _confirmDelete(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dlg) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Delete "${conv.title}"? All messages will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlg, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dlg, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final deleted = await notifier.deleteConversation(conv.id);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(deleted ? 'Conversation deleted' : 'Failed to delete'),
        backgroundColor: deleted ? AppColors.success : AppColors.error,
      ));
    }
  }
}

class _ChatbotConfigDialog extends StatefulWidget {
  final Map<String, dynamic> config;
  final ChatbotNotifier notifier;
  const _ChatbotConfigDialog({required this.config, required this.notifier});
  @override
  State<_ChatbotConfigDialog> createState() => _ChatbotConfigDialogState();
}

class _ChatbotConfigDialogState extends State<_ChatbotConfigDialog> {
  late double _temperature;
  late int _maxTokens;
  late bool _emergencyDetection;
  late int _contextWindow;
  late String _safetySettings;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.config;
    _temperature      = (c['temperature'] as num?)?.toDouble() ?? 0.7;
    _maxTokens        = (c['max_tokens'] as num?)?.toInt() ?? 2048;
    _emergencyDetection = c['emergency_detection_enabled'] as bool? ?? true;
    _contextWindow    = (c['context_window'] as num?)?.toInt() ?? 10;
    _safetySettings   = c['safety_settings'] as String? ?? 'high';
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.smart_toy_rounded, color: AppColors.accent),
                const SizedBox(width: 10),
                Text('Chatbot Configuration',
                    style: Theme.of(context).textTheme.headlineSmall),
              ]),
              const SizedBox(height: 4),
              Text('Changes require Super Admin privileges.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.lightTextMuted)),
              const SizedBox(height: 20),

              // Model (read-only label)
              _labelRow(context, 'Model', widget.config['model']?.toString() ?? 'gemini-1.5-flash'),
              const SizedBox(height: 16),

              // Temperature slider
              Row(children: [
                Expanded(child: Text('Temperature', style: Theme.of(context).textTheme.bodyMedium)),
                Text(_temperature.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.accent)),
              ]),
              Slider(
                value: _temperature,
                min: 0.0, max: 1.0, divisions: 20,
                label: _temperature.toStringAsFixed(2),
                activeColor: AppColors.accent,
                onChanged: (v) => setState(() => _temperature = v),
              ),
              const SizedBox(height: 8),

              // Max tokens
              TextFormField(
                initialValue: '$_maxTokens',
                decoration: const InputDecoration(
                    labelText: 'Max Tokens', isDense: true),
                keyboardType: TextInputType.number,
                onChanged: (v) => _maxTokens = int.tryParse(v) ?? _maxTokens,
              ),
              const SizedBox(height: 12),

              // Context window
              TextFormField(
                initialValue: '$_contextWindow',
                decoration: const InputDecoration(
                    labelText: 'Context Window (messages)', isDense: true),
                keyboardType: TextInputType.number,
                onChanged: (v) => _contextWindow = int.tryParse(v) ?? _contextWindow,
              ),
              const SizedBox(height: 12),

              // Safety settings
              DropdownButtonFormField<String>(
                initialValue: _safetySettings,
                decoration: const InputDecoration(
                    labelText: 'Safety Settings', isDense: true),
                items: ['low', 'medium', 'high', 'block_all']
                    .map((s) => DropdownMenuItem(value: s,
                        child: Text(s.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => _safetySettings = v!),
              ),
              const SizedBox(height: 12),

              // Emergency detection toggle
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Emergency Detection', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Flag messages with emergency keywords',
                    style: TextStyle(fontSize: 12)),
                value: _emergencyDetection,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _emergencyDetection = v),
              ),

              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                  child: _saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Config'),
                )),
              ]),
            ]),
          ),
        ),
      );

  Widget _labelRow(BuildContext context, String label, String value) => Row(children: [
        SizedBox(width: 140, child: Text(label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.lightTextMuted, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
      ]);

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await widget.notifier.updateConfig({
      'temperature': _temperature,
      'max_tokens': _maxTokens,
      'emergency_detection_enabled': _emergencyDetection,
      'context_window': _contextWindow,
      'safety_settings': _safetySettings,
    });
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Chatbot configuration saved' : 'Failed to save config'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }
}

class _LangFilter extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _LangFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: const Text('All languages', style: TextStyle(fontSize: 13)),
          items: [
            const DropdownMenuItem(value: null, child: Text('All languages')),
            ...['en', 'ne', 'hi', 'bh'].map((l) =>
                DropdownMenuItem(value: l, child: Text(l.toUpperCase(),
                    style: const TextStyle(fontSize: 13)))),
          ],
          onChanged: onChanged, isDense: true,
        ),
      );
}

class _EmergencyFilter extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _EmergencyFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: value,
          hint: const Text('All convs', style: TextStyle(fontSize: 13)),
          items: const [
            DropdownMenuItem(value: null, child: Text('All convs')),
            DropdownMenuItem(value: true, child: Text('Has emergency')),
            DropdownMenuItem(value: false, child: Text('No emergency')),
          ],
          onChanged: onChanged, isDense: true,
        ),
      );
}
