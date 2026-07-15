import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/medical_image_record.dart';
import '../providers/health_records_provider.dart';

class MedicalImagesPage extends ConsumerWidget {
  const MedicalImagesPage({super.key});

  static const _types = [
    ('all',          'All',          '📁'),
    ('xray',         'X-Ray',        '🩻'),
    ('mri',          'MRI',          '🧠'),
    ('ct_scan',      'CT Scan',      '🔬'),
    ('blood_report', 'Blood Report', '🩸'),
    ('ecg',          'ECG',          '❤️'),
    ('skin',         'Skin',         '🫀'),
    ('other',        'Other',        '📄'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(healthRecordsControllerProvider);
    final ctrl   = ref.read(healthRecordsControllerProvider.notifier);
    final images = state.filteredImages;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Row(children: [
          Text('🩻', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Medical Images',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: DesignTokens.textStrong)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded,
                color: DesignTokens.primary),
            tooltip: 'Upload image',
            onPressed: () => _showUploadSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Type filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t = _types[i];
                final isActive = i == 0
                    ? state.activeImageType == null
                    : state.activeImageType == t.$1;
                return FilterChip(
                  label: Text('${t.$3} ${t.$2}'),
                  selected: isActive,
                  onSelected: (_) =>
                      ctrl.setImageTypeFilter(i == 0 ? null : t.$1),
                  selectedColor: DesignTokens.blue.withValues(alpha: 0.15),
                  checkmarkColor: DesignTokens.blue,
                  labelStyle: TextStyle(
                    color: isActive ? DesignTokens.blue : DesignTokens.textMuted,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isActive
                        ? DesignTokens.blue.withValues(alpha: 0.4)
                        : DesignTokens.border,
                  ),
                  backgroundColor: DesignTokens.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: DesignTokens.blue))
                : images.isEmpty
                    ? _EmptyImages(
                        onUpload: () => _showUploadSheet(context, ref))
                    : GridView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: images.length,
                        itemBuilder: (_, i) => _ImageCard(
                          image: images[i],
                          onTap: () => _push(context,
                              _ImageViewerPage(image: images[i])),
                          onDelete: () => _confirmDelete(context, ref, images[i]),
                        )
                            .animate(delay: (i * 55).ms)
                            .fadeIn(duration: 300.ms)
                            .scale(begin: const Offset(0.9, 0.9)),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadSheet(context, ref),
        backgroundColor: DesignTokens.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Add Scan',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showUploadSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadImageSheet(ref: ref),
    );
  }

  void _confirmDelete(
      BuildContext ctx, WidgetRef ref, MedicalImageRecord image) {
    showDialog<void>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: const Text('Delete Image'),
        content: Text('Remove "${image.title}" from your records?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.danger,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(dctx);
              ref
                  .read(healthRecordsControllerProvider.notifier)
                  .removeMedicalImage(image.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Image card ───────────────────────────────────────────────────────────────

class _ImageCard extends StatelessWidget {
  final MedicalImageRecord image;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _ImageCard(
      {required this.image, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const color = DesignTokens.blue;
    return Material(
      color: DesignTokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail / type icon
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(image.typeEmoji,
                            style: const TextStyle(fontSize: 52)),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  DesignTokens.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                size: 16, color: DesignTokens.danger),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            image.typeLabel,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      image.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.textStrong),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (image.bodyPart != null) ...[
                      const SizedBox(height: 2),
                      Text(image.bodyPart!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: DesignTokens.textMuted)),
                    ],
                    if (image.scanDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(image.scanDate!),
                        style: const TextStyle(
                            fontSize: 11, color: DesignTokens.textSubtle),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Full-screen image viewer ─────────────────────────────────────────────────

class _ImageViewerPage extends StatelessWidget {
  final MedicalImageRecord image;
  const _ImageViewerPage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(image.title,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Image placeholder (real impl would use cached_network_image)
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(image.typeEmoji,
                          style: const TextStyle(fontSize: 96)),
                      const SizedBox(height: 16),
                      Text(
                        image.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        image.typeLabel,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Metadata panel
          Container(
            color: const Color(0xFF12122A),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image.description != null)
                  Text(image.description!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13, height: 1.5)),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 8, children: [
                  if (image.doctorName != null)
                    _MetaChip('👨‍⚕️ ${image.doctorName!}'),
                  if (image.hospitalName != null)
                    _MetaChip('🏥 ${image.hospitalName!}'),
                  if (image.scanDate != null)
                    _MetaChip('📅 ${DateFormat('d MMM yyyy').format(image.scanDate!)}'),
                  if (image.fileSizeBytes != null)
                    _MetaChip('💾 ${image.fileSizeFormatted}'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  const _MetaChip(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      );
}

// ─── Upload sheet ─────────────────────────────────────────────────────────────

class _UploadImageSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _UploadImageSheet({required this.ref});

  @override
  ConsumerState<_UploadImageSheet> createState() => _UploadImageSheetState();
}

class _UploadImageSheetState extends ConsumerState<_UploadImageSheet> {
  final _titleCtrl   = TextEditingController();
  final _bodyCtrl    = TextEditingController();
  final _doctorCtrl  = TextEditingController();
  String _imageType  = 'xray';
  bool _saving       = false;

  static const _typeOptions = [
    ('xray',         '🩻 X-Ray'),
    ('mri',          '🧠 MRI Scan'),
    ('ct_scan',      '🔬 CT Scan'),
    ('blood_report', '🩸 Blood Report'),
    ('ecg',          '❤️ ECG'),
    ('skin',         '🫀 Skin Image'),
    ('other',        '📄 Other'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _doctorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: DesignTokens.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('🩻 Upload Medical Image',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong)),
            const SizedBox(height: 20),
            _field(_titleCtrl, 'Image Title *', Icons.title_rounded),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _imageType,
              decoration: _inputDeco('Image Type'),
              onChanged: (v) => setState(() => _imageType = v!),
              items: _typeOptions
                  .map((o) =>
                      DropdownMenuItem(value: o.$1, child: Text(o.$2)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            _field(_bodyCtrl, 'Body Part (optional)', Icons.accessibility_new_rounded),
            const SizedBox(height: 12),
            _field(_doctorCtrl, 'Doctor Name (optional)', Icons.person_outline_rounded),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Upload Image',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon) =>
      TextField(
        controller: c,
        decoration: _inputDeco(label, icon: icon),
      );

  InputDecoration _inputDeco(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: DesignTokens.blue)
            : null,
        filled: true,
        fillColor: DesignTokens.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    final image = MedicalImageRecord(
      id:          '',
      userId:      'local',
      title:       title,
      imageType:   _imageType,
      bodyPart:    _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
      doctorName:  _doctorCtrl.text.trim().isEmpty ? null : _doctorCtrl.text.trim(),
      tags:        const [],
      createdAt:   DateTime.now(),
    );

    final ok = await ref
        .read(healthRecordsControllerProvider.notifier)
        .addMedicalImage(image);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) Navigator.of(context).pop();
    }
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyImages extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyImages({required this.onUpload});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🩻', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text('No Medical Images',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong)),
              const SizedBox(height: 8),
              const Text(
                  'Upload X-Rays, MRI scans, CT scans and blood reports here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: DesignTokens.textMuted, height: 1.5)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: const Text('Upload Image'),
                style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.blue,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
}

void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
