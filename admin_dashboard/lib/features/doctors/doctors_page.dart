import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'doctors_provider.dart';

class DoctorsPage extends ConsumerStatefulWidget {
  const DoctorsPage({super.key});
  @override
  ConsumerState<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends ConsumerState<DoctorsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorsProvider);
    final notifier = ref.read(doctorsProvider.notifier);
    final active = state.doctors.where((d) => d.isActive).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Doctor Management',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('${state.total} doctors registered in the system',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          OutlinedButton.icon(
            onPressed: () => _showAddDoctorDialog(context, notifier),
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Add Doctor'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => notifier.load(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // Stats
        LayoutBuilder(builder: (context, cst) {
          final cols = cst.maxWidth > 700 ? 3 : 2;
          return GridView.count(
            crossAxisCount: cols, crossAxisSpacing: 16,
            mainAxisSpacing: 16, childAspectRatio: 1.7,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(title: 'Total Doctors', value: '${state.total}',
                  icon: Icons.medical_services_rounded, color: AppColors.info, animDelay: 0),
              StatCard(title: 'Active', value: '$active',
                  icon: Icons.check_circle_rounded, color: AppColors.success, animDelay: 80),
              StatCard(title: 'Inactive', value: '${state.total - active}',
                  icon: Icons.pause_circle_rounded, color: AppColors.warning, animDelay: 160),
            ],
          );
        }),
        const SizedBox(height: 24),

        // Table
        DataTableCard(
          title: 'All Doctors',
          isLoading: state.isLoading,
          totalRows: state.total,
          currentPage: state.page,
          pageSize: state.pageSize,
          onPageChanged: (p) => notifier.goToPage(p),
          searchBar: SearchField(
            controller: _searchCtrl,
            hint: 'Search doctors...',
            onChanged: (v) { if (v.isEmpty || v.length >= 2) notifier.setSearch(v); },
          ),
          filters: [
            _StatusFilter(value: state.activeFilter, onChanged: notifier.setActiveFilter),
          ],
          columns: const [
            DataColumn(label: Text('Doctor')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Verified')),
            DataColumn(label: Text('Joined')),
            DataColumn(label: Text('Last Login')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.doctors.map((d) => DataRow(cells: [
            DataCell(_DoctorNameCell(doctor: d)),
            DataCell(Text(d.email, style: Theme.of(context).textTheme.bodySmall)),
            DataCell(Text(d.phone ?? '—', style: Theme.of(context).textTheme.bodySmall)),
            DataCell(StatusBadge(active: d.isActive)),
            DataCell(_VerifiedBadge(emailVerified: d.emailVerified, phoneVerified: d.phoneVerified)),
            DataCell(Text(DateFormat('MMM d, y').format(d.createdAt),
                style: Theme.of(context).textTheme.bodySmall)),
            DataCell(Text(d.lastLogin != null
                ? DateFormat('MMM d').format(d.lastLogin!)
                : 'Never', style: Theme.of(context).textTheme.bodySmall)),
            DataCell(_DoctorActions(doctor: d, notifier: notifier)),
          ])).toList(),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }

  void _showAddDoctorDialog(BuildContext context, DoctorsNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddDoctorDialog(notifier: notifier),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _DoctorNameCell extends StatelessWidget {
  final DoctorItem doctor;
  const _DoctorNameCell({required this.doctor});
  @override
  Widget build(BuildContext context) {
    final initials = doctor.fullName.isNotEmpty ? doctor.fullName[0].toUpperCase() : 'D';
    return Row(children: [
      Container(width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppColors.infoSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(initials,
              style: const TextStyle(color: AppColors.info,
                  fontWeight: FontWeight.w700, fontSize: 12)))),
      const SizedBox(width: 10),
      Text(doctor.fullName, style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(fontWeight: FontWeight.w500)),
    ]);
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool emailVerified;
  final bool phoneVerified;
  const _VerifiedBadge({required this.emailVerified, required this.phoneVerified});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Tooltip(message: emailVerified ? 'Email verified' : 'Email not verified',
            child: Icon(Icons.email_rounded, size: 14,
                color: emailVerified ? AppColors.success : AppColors.lightTextLight)),
        const SizedBox(width: 6),
        Tooltip(message: phoneVerified ? 'Phone verified' : 'Phone not verified',
            child: Icon(Icons.phone_rounded, size: 14,
                color: phoneVerified ? AppColors.success : AppColors.lightTextLight)),
      ]);
}

class _DoctorActions extends StatelessWidget {
  final DoctorItem doctor;
  final DoctorsNotifier notifier;
  const _DoctorActions({required this.doctor, required this.notifier});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Tooltip(
          message: doctor.isActive ? 'Deactivate' : 'Activate',
          child: IconButton(
            icon: Icon(
                doctor.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                size: 16,
                color: doctor.isActive ? AppColors.warning : AppColors.success),
            onPressed: () async {
              await notifier.updateStatus(doctor.id, !doctor.isActive);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${doctor.fullName} ${doctor.isActive ? 'deactivated' : 'activated'}'),
                  backgroundColor: doctor.isActive ? AppColors.warning : AppColors.success,
                ));
              }
            },
          ),
        ),
        Tooltip(
          message: 'View Details',
          child: IconButton(
            icon: const Icon(Icons.visibility_rounded, size: 16, color: AppColors.info),
            onPressed: () => _showDetails(context),
          ),
        ),
      ]);

  void _showDetails(BuildContext context) {
    showDialog(context: context, builder: (_) => Dialog(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Doctor Profile', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                _row(context, 'Name', doctor.fullName),
                _row(context, 'Email', doctor.email),
                _row(context, 'Phone', doctor.phone ?? '—'),
                _row(context, 'Status', doctor.isActive ? 'Active' : 'Inactive'),
                _row(context, 'Email Verified', doctor.emailVerified ? 'Yes' : 'No'),
                _row(context, 'Phone Verified', doctor.phoneVerified ? 'Yes' : 'No'),
                _row(context, 'Joined', DateFormat('MMMM d, y').format(doctor.createdAt)),
                if (doctor.lastLogin != null)
                  _row(context, 'Last Login', DateFormat('MMMM d, y HH:mm').format(doctor.lastLogin!)),
                const SizedBox(height: 20),
                Align(alignment: Alignment.centerRight,
                    child: FilledButton(onPressed: () => Navigator.pop(context),
                        child: const Text('Close'))),
              ]))),
    ));
  }

  Widget _row(BuildContext context, String label, String value) =>
      Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            SizedBox(width: 130, child: Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.lightTextMuted))),
            Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600))),
          ]));
}

class _StatusFilter extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _StatusFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<bool?>(
            value: value, isDense: true,
            hint: const Text('All status', style: TextStyle(fontSize: 13)),
            items: const [
              DropdownMenuItem(value: null, child: Text('All status')),
              DropdownMenuItem(value: true, child: Text('Active')),
              DropdownMenuItem(value: false, child: Text('Inactive')),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}

class _AddDoctorDialog extends StatefulWidget {
  final DoctorsNotifier notifier;
  const _AddDoctorDialog({required this.notifier});
  @override
  State<_AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<_AddDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _email.dispose();
    _password.dispose(); _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  const Icon(Icons.medical_services_rounded, color: AppColors.info),
                  const SizedBox(width: 10),
                  Text('Register New Doctor',
                      style: Theme.of(context).textTheme.headlineSmall),
                ]),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Container(padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(_error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13))),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_rounded)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email Address *',
                      prefixIcon: Icon(Icons.email_rounded)),
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock_rounded)),
                  validator: (v) => (v?.length ?? 0) < 8 ? 'Min 8 characters' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone (optional)',
                      prefixIcon: Icon(Icons.phone_rounded)),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.info),
                    child: _loading
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Register Doctor'),
                  )),
                ]),
              ]),
            ),
          ),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await widget.notifier.createDoctor(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() { _loading = false; _error = 'Failed to create doctor account.'; });
    }
  }
}
