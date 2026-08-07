import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import 'profile_provider.dart';
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _profileSearchCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _profileSearchCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('User Profiles',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('Manage user profiles, addresses, emergency contacts and medical information',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          FilledButton.icon(
            onPressed: () {
              notifier.loadProfiles();
              notifier.loadAddresses();
              notifier.loadEmergencyContacts();
              notifier.loadMedicalInfos();
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),
        Card(child: Column(children: [
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabs: const [
              Tab(text: 'User Profiles'),
              Tab(text: 'Addresses'),
              Tab(text: 'Emergency Contacts'),
              Tab(text: 'Medical Info'),
            ],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
          ),
          SizedBox(
            height: 620,
            child: TabBarView(controller: _tab, children: [
              _UserProfilesTab(
                  state: state, notifier: notifier, searchCtrl: _profileSearchCtrl),
              _AddressesTab(state: state, notifier: notifier),
              _EmergencyContactsTab(state: state, notifier: notifier),
              _MedicalInfoTab(state: state, notifier: notifier),
            ]),
          ),
        ])).animate().fadeIn(delay: 200.ms),
      ]),
    );
  }
}

// ── User Profiles Tab ─────────────────────────────────────────────────────────

class _UserProfilesTab extends StatelessWidget {
  final ProfileState state;
  final ProfileNotifier notifier;
  final TextEditingController searchCtrl;
  const _UserProfilesTab({required this.state, required this.notifier, required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'User Profiles',
        isLoading: state.isLoading,
        totalRows: state.profilesTotal,
        currentPage: state.profilesPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadProfiles(page: p),
        searchBar: SearchField(
          controller: searchCtrl,
          hint: 'Search by name or email...',
          onChanged: (v) { if (v.isEmpty || v.length >= 2) notifier.setProfileSearch(v); },
        ),
        columns: const [
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Date of Birth')),
          DataColumn(label: Text('Gender')),
          DataColumn(label: Text('Blood Group')),
          DataColumn(label: Text('Height')),
          DataColumn(label: Text('Weight')),
          DataColumn(label: Text('Occupation')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.profiles.map((p) => DataRow(cells: [
          DataCell(_patientCell(context, p.userName, p.userEmail)),
          DataCell(Text(p.dateOfBirth != null ? _fmtDate(p.dateOfBirth!) : '—',
              style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.gender ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.bloodGroup ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.heightCm != null ? '${p.heightCm!.toStringAsFixed(0)} cm' : '—',
              style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.weightKg != null ? '${p.weightKg!.toStringAsFixed(0)} kg' : '—',
              style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.occupation ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              icon: const Icon(Icons.visibility_rounded, size: 16, color: AppColors.primary),
              onPressed: () => _showDetail(context, p),
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.accent),
              onPressed: () => _showEditDialog(context, p),
            ),
          ])),
        ])).toList(),
      ),
    );
  }

  Widget _patientCell(BuildContext context, String? name, String? email) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        if (email != null)
          Text(email, style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.lightTextMuted)),
      ]);

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    return dt != null ? DateFormat('MMM d, y').format(dt) : iso;
  }

  void _showDetail(BuildContext context, AdminUserProfile p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Profile — ${p.userName ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                _dRow(context, 'Email', p.userEmail ?? '—'),
                _dRow(context, 'Date of Birth', p.dateOfBirth != null ? _fmtDate(p.dateOfBirth!) : '—'),
                _dRow(context, 'Gender', p.gender ?? '—'),
                _dRow(context, 'Blood Group', p.bloodGroup ?? '—'),
                _dRow(context, 'Height', p.heightCm != null ? '${p.heightCm} cm' : '—'),
                _dRow(context, 'Weight', p.weightKg != null ? '${p.weightKg} kg' : '—'),
                _dRow(context, 'Occupation', p.occupation ?? '—'),
                _dRow(context, 'Marital Status', p.maritalStatus ?? '—'),
                _dRow(context, 'Bio', p.bio ?? '—'),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight,
                    child: FilledButton(onPressed: () => Navigator.pop(context),
                        child: const Text('Close'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AdminUserProfile p) {
    showDialog(
      context: context,
      builder: (_) => _EditProfileDialog(profile: p),
    );
  }

  Widget _dRow(BuildContext context, String label, String value) =>
      Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 130, child: Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.lightTextMuted, fontWeight: FontWeight.w600))),
            Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w500))),
          ]));
}

class _EditProfileDialog extends StatefulWidget {
  final AdminUserProfile profile;
  const _EditProfileDialog({required this.profile});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _bioCtrl;
  String? _gender;
  String? _maritalStatus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _occupationCtrl = TextEditingController(text: widget.profile.occupation ?? '');
    _bioCtrl = TextEditingController(text: widget.profile.bio ?? '');
    _gender = widget.profile.gender;
    _maritalStatus = widget.profile.maritalStatus;
  }

  @override
  void dispose() {
    _occupationCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Edit Profile — ${widget.profile.userName ?? 'User'}',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['male', 'female', 'other', 'prefer_not_to_say']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.replaceAll('_', ' ').toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _maritalStatus,
                decoration: const InputDecoration(labelText: 'Marital Status'),
                items: ['single', 'married', 'divorced', 'widowed']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _maritalStatus = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _occupationCtrl,
                decoration: const InputDecoration(labelText: 'Occupation'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save'),
                )),
              ]),
            ]),
          ),
        ),
      );

  Future<void> _save() async {
    setState(() => _loading = true);
    // Build the notifier from the surrounding ProviderScope
    // We look it up at save-time from the widget tree
    try {
      // Retrieve the ProfileNotifier from the ProviderScope
      final container = ProviderScope.containerOf(context);
      final notifier = container.read(profileProvider.notifier);
      final ok = await notifier.updateProfile(
        widget.profile.id,
        gender: _gender,
        maritalStatus: _maritalStatus,
        occupation: _occupationCtrl.text.trim().isEmpty ? null : _occupationCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      );
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Profile updated successfully' : 'Failed to update profile'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }
}

// ── Addresses Tab ─────────────────────────────────────────────────────────────

class _AddressesTab extends StatelessWidget {
  final ProfileState state;
  final ProfileNotifier notifier;
  const _AddressesTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'User Addresses',
        isLoading: state.isLoading,
        totalRows: state.addressesTotal,
        currentPage: state.addressesPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadAddresses(page: p),
        columns: const [
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Street')),
          DataColumn(label: Text('Municipality')),
          DataColumn(label: Text('District')),
          DataColumn(label: Text('State')),
          DataColumn(label: Text('Country')),
          DataColumn(label: Text('Postal Code')),
          DataColumn(label: Text('Primary')),
        ],
        rows: state.addresses.map((a) => DataRow(cells: [
          DataCell(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(a.userName ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              if (a.userEmail != null)
                Text(a.userEmail!, style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: AppColors.lightTextMuted)),
            ],
          )),
          DataCell(_typeBadge(a.addressType)),
          DataCell(Text(a.street ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(a.municipality ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(a.district ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(a.state ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(a.country ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(a.postalCode ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Icon(
            a.isPrimary ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16,
            color: a.isPrimary ? AppColors.warning : AppColors.lightTextMuted,
          )),
        ])).toList(),
      ),
    );
  }

  Widget _typeBadge(String type) {
    final color = switch (type.toLowerCase()) {
      'home' => AppColors.primary,
      'work' => AppColors.accent,
      'other' => AppColors.lightTextMuted,
      _ => AppColors.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(type.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Emergency Contacts Tab ────────────────────────────────────────────────────

class _EmergencyContactsTab extends StatelessWidget {
  final ProfileState state;
  final ProfileNotifier notifier;
  const _EmergencyContactsTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'Emergency Contacts',
        isLoading: state.isLoading,
        totalRows: state.emergencyContactsTotal,
        currentPage: state.emergencyContactsPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadEmergencyContacts(page: p),
        columns: const [
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Contact Name')),
          DataColumn(label: Text('Relationship')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Priority')),
        ],
        rows: state.emergencyContacts.map((c) => DataRow(cells: [
          DataCell(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(c.userName ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              if (c.userEmail != null)
                Text(c.userEmail!, style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: AppColors.lightTextMuted)),
            ],
          )),
          DataCell(Text(c.contactName, style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w500))),
          DataCell(Text(c.contactRelationship, style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(c.phone, style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(c.email ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.priority == 1 ? AppColors.errorSurface : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('#${c.priority}',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: c.priority == 1 ? AppColors.error : AppColors.lightTextMuted)),
          )),
        ])).toList(),
      ),
    );
  }
}

// ── Medical Info Tab ──────────────────────────────────────────────────────────

class _MedicalInfoTab extends StatelessWidget {
  final ProfileState state;
  final ProfileNotifier notifier;
  const _MedicalInfoTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'Medical Information',
        isLoading: state.isLoading,
        totalRows: state.medicalInfosTotal,
        currentPage: state.medicalInfosPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadMedicalInfos(page: p),
        columns: const [
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Blood Group')),
          DataColumn(label: Text('Allergies')),
          DataColumn(label: Text('Chronic Diseases')),
          DataColumn(label: Text('Medications')),
          DataColumn(label: Text('Smoking')),
          DataColumn(label: Text('Alcohol')),
          DataColumn(label: Text('Notes')),
        ],
        rows: state.medicalInfos.map((m) => DataRow(cells: [
          DataCell(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(m.userName ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              if (m.userEmail != null)
                Text(m.userEmail!, style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: AppColors.lightTextMuted)),
            ],
          )),
          DataCell(Text(m.bloodGroup ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text('${m.allergies.length}', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text('${m.chronicDiseases.length}', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text('${m.currentMedications.length}', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Icon(
            m.smokingStatus ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: m.smokingStatus ? AppColors.error : AppColors.success,
          )),
          DataCell(Icon(
            m.alcoholConsumption ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: m.alcoholConsumption ? AppColors.warning : AppColors.success,
          )),
          DataCell(SizedBox(
            width: 120,
            child: Text(m.notes ?? '—',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis),
          )),
        ])).toList(),
      ),
    );
  }
}
