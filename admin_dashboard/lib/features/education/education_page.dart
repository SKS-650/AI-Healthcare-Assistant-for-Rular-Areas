import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import 'education_provider.dart';

class EducationPage extends ConsumerStatefulWidget {
  const EducationPage({super.key});

  @override
  ConsumerState<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends ConsumerState<EducationPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(educationProvider);
    final notifier = ref.read(educationProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health Education',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700))
                      .animate()
                      .fadeIn(duration: 400.ms),
                  Text(
                    '${state.total} articles in the knowledge base',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.lightTextMuted),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showArticleDialog(context, null),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New Article'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
            ).animate().fadeIn(delay: 200.ms),
          ]),
          const SizedBox(height: 24),

          // ── Table ────────────────────────────────────────────────────────
          DataTableCard(
            title: 'Articles',
            isLoading: state.isLoading,
            totalRows: state.total,
            currentPage: state.page,
            pageSize: state.pageSize,
            onPageChanged: notifier.goToPage,
            searchBar: SearchField(
              controller: _searchCtrl,
              hint: 'Search articles...',
              onChanged: (v) {
                if (v.isEmpty || v.length >= 2) notifier.setSearch(v);
              },
            ),
            filters: [
              DropdownButtonHideUnderline(
                child: DropdownButton<bool?>(
                  value: state.publishedFilter,
                  isDense: true,
                  hint: const Text('All status',
                      style: TextStyle(fontSize: 13)),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All status')),
                    DropdownMenuItem(value: true,  child: Text('Published')),
                    DropdownMenuItem(value: false, child: Text('Draft')),
                  ],
                  onChanged: notifier.setPublishedFilter,
                ),
              ),
            ],
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Language')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Views')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: state.articles.map((a) => DataRow(cells: [
                  DataCell(_ArticleTitleCell(article: a)),
                  DataCell(Text(a.categoryName ?? '—',
                      style: Theme.of(context).textTheme.bodySmall)),
                  DataCell(_LangChip(lang: a.language)),
                  DataCell(StatusBadge(
                      active: a.isPublished,
                      activeLabel: 'Published',
                      inactiveLabel: 'Draft')),
                  DataCell(Row(children: [
                    const Icon(Icons.visibility_outlined,
                        size: 14, color: AppColors.lightTextMuted),
                    const SizedBox(width: 4),
                    Text('${a.viewCount}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ])),
                  DataCell(Text(
                      DateFormat('MMM d, y').format(a.createdAt),
                      style: Theme.of(context).textTheme.bodySmall)),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 16, color: AppColors.info),
                        onPressed: () => _showArticleDialog(context, a),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 16, color: AppColors.error),
                        onPressed: () => _confirmDelete(context, a),
                        tooltip: 'Delete',
                      ),
                    ],
                  )),
                ])).toList(),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  // ── Article dialog via proper StatefulWidget ──────────────────────────────
  void _showArticleDialog(BuildContext context, HealthArticle? article) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ArticleDialog(
        article: article,
        onSave: (data) async {
          bool ok;
          if (article == null) {
            ok = await ref
                .read(educationProvider.notifier)
                .createArticle(data);
          } else {
            ok = await ref
                .read(educationProvider.notifier)
                .updateArticle(article.id, data);
          }
          return ok;
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, HealthArticle article) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Article'),
        content: Text('Delete "${article.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(educationProvider.notifier)
                  .deleteArticle(article.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Article dialog — StatefulWidget so controllers are disposed properly ──────
class _ArticleDialog extends StatefulWidget {
  final HealthArticle? article;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const _ArticleDialog({this.article, required this.onSave});

  @override
  State<_ArticleDialog> createState() => _ArticleDialogState();
}

class _ArticleDialogState extends State<_ArticleDialog> {
  late final _titleCtrl   = TextEditingController(text: widget.article?.title   ?? '');
  late final _summaryCtrl = TextEditingController(text: widget.article?.summary ?? '');
  late final _contentCtrl = TextEditingController(text: widget.article?.content ?? '');
  late final _authorCtrl  = TextEditingController(text: widget.article?.author  ?? '');

  late bool   _isPublished = widget.article?.isPublished ?? true;
  late bool   _isFeatured  = widget.article?.isFeatured  ?? false;
  late String _language    = widget.article?.language    ?? 'en';
  bool        _saving      = false;
  String?     _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    _contentCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title and Content are required.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final ok = await widget.onSave({
      'title':        _titleCtrl.text.trim(),
      'summary':      _summaryCtrl.text.trim(),
      'content':      _contentCtrl.text.trim(),
      'author':       _authorCtrl.text.trim(),
      'language':     _language,
      'is_published': _isPublished,
      'is_featured':  _isFeatured,
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() { _saving = false; _error = 'Failed to save. Try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.article == null;
    return AlertDialog(
      title: Text(isNew ? 'New Article' : 'Edit Article'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.error)),
                ),
              TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title *')),
              const SizedBox(height: 12),
              TextField(
                  controller: _summaryCtrl,
                  decoration: const InputDecoration(labelText: 'Summary'),
                  maxLines: 2),
              const SizedBox(height: 12),
              TextField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(labelText: 'Content *'),
                  maxLines: 6),
              const SizedBox(height: 12),
              TextField(
                  controller: _authorCtrl,
                  decoration: const InputDecoration(labelText: 'Author')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _language,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ne', child: Text('Nepali')),
                  DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                ],
                onChanged: (v) => setState(() => _language = v ?? 'en'),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                title: const Text('Published'),
                value: _isPublished,
                onChanged: (v) => setState(() => _isPublished = v),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('Featured'),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(isNew ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────
class _ArticleTitleCell extends StatelessWidget {
  final HealthArticle article;
  const _ArticleTitleCell({required this.article});

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(article.emoji ?? '📄',
            style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: Text(article.title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
      ]);
}

class _LangChip extends StatelessWidget {
  final String lang;
  const _LangChip({required this.lang});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: AppColors.accentSurface,
            borderRadius: BorderRadius.circular(6)),
        child: Text(lang.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.accent)),
      );
}
