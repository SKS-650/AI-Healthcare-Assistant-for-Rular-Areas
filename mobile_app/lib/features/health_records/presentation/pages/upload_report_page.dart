import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_record.dart';
import '../controllers/health_records_state.dart';
import '../providers/health_records_provider.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/upload/upload_area.dart';
import '../widgets/upload/upload_option_tile.dart';
import '../widgets/upload/upload_progress.dart';
import '../widgets/upload/upload_success_dialog.dart';

class UploadReportPage extends ConsumerStatefulWidget {
  const UploadReportPage({super.key});

  @override
  ConsumerState<UploadReportPage> createState() => _UploadReportPageState();
}

class _UploadReportPageState extends ConsumerState<UploadReportPage> {
  final _titleController = TextEditingController(
    text: 'Uploaded Medical Report',
  );
  final _doctorController = TextEditingController(text: 'Dr. Asha Karki');
  final _notesController = TextEditingController();
  String _category = 'Consultation';

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final success = await ref
        .read(healthRecordsControllerProvider.notifier)
        .upload(
          UploadRecord(
            title: title,
            category: _category,
            doctorName: _doctorController.text.trim(),
            recordDate: DateTime.now(),
            notes: _notesController.text.trim(),
          ),
        );
    if (!mounted || !success) return;
    await showDialog<void>(
      context: context,
      builder: (_) => const UploadSuccessDialog(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(
      healthRecordsControllerProvider.select((state) => state.status),
    );
    final isUploading = status == HealthRecordsStatus.uploading;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Report')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const UploadArea(),
          const UploadOptionTile(
            icon: Icons.camera_alt_outlined,
            title: 'Scan paper report',
            subtitle: 'Use a photo as a dummy attachment.',
          ),
          const UploadOptionTile(
            icon: Icons.folder_open_outlined,
            title: 'Choose file',
            subtitle: 'Attach PDF, image, or document placeholder.',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Report title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Consultation',
                      child: Text('Consultation'),
                    ),
                    DropdownMenuItem(
                      value: 'Lab Report',
                      child: Text('Lab Report'),
                    ),
                    DropdownMenuItem(
                      value: 'Prescription',
                      child: Text('Prescription'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _doctorController,
                  decoration: const InputDecoration(labelText: 'Doctor name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          if (isUploading) const UploadProgress(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: isUploading ? 'Uploading' : 'Upload dummy record',
              icon: Icons.upload_file_outlined,
              onPressed: isUploading ? null : _upload,
            ),
          ),
        ],
      ),
    );
  }
}
