import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../../domain/entities/emergency_contact.dart';
import '../providers/emergency_provider.dart';

// ─── National helpline definitions ───────────────────────────────────────────
const _kHelplines = [
  (emoji: '🚑', num: '102',  label: 'Ambulance',  color: Color(0xFFDC2626)),
  (emoji: '🚓', num: '100',  label: 'Police',     color: Color(0xFF1D4ED8)),
  (emoji: '🔥', num: '101',  label: 'Fire',       color: Color(0xFFEA580C)),
  (emoji: '🏥', num: '104',  label: 'Health',     color: Color(0xFF059669)),
  (emoji: '🆘', num: '108',  label: 'Disaster',   color: Color(0xFF7C3AED)),
  (emoji: '☎️', num: '112',  label: 'Emergency',  color: Color(0xFF0284C7)),
];

class EmergencyContactsPage extends ConsumerStatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  ConsumerState<EmergencyContactsPage> createState() =>
      _EmergencyContactsPageState();
}

class _EmergencyContactsPageState
    extends ConsumerState<EmergencyContactsPage> {
  // Form controllers kept here so the sheet can read them
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _relationCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emergencyControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(children: [
          Text('📞', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text('Emergency Contacts',
              style: TextStyle(color: DesignTokens.textStrong)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () => _showAddSheet(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add', style: TextStyle(fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tip banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignTokens.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(children: [
              Text('💡', style: TextStyle(fontSize: 14)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap any number to call immediately. '
                  'Personal contacts are notified on SOS.',
                  style: TextStyle(
                      color: DesignTokens.primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
          ),

          // ── National Helplines ─────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              Text('🏛️', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text('National Helplines',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: DesignTokens.textStrong)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.35,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _kHelplines
                  .map((h) => _HelplineTile(
                        emoji: h.emoji,
                        number: h.num,
                        label: h.label,
                        color: h.color,
                      ))
                  .toList(),
            ),
          ),

          // ── Personal Contacts ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(children: [
                  Text('👤', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text('Personal Contacts',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: DesignTokens.textStrong)),
                ]),
                Text('${state.contacts.length} saved',
                    style: const TextStyle(
                        color: DesignTokens.textMuted, fontSize: 12)),
              ],
            ),
          ),

          Expanded(
            child: state.contacts.isEmpty
                ? _EmptyContacts(onAdd: () => _showAddSheet(context))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: state.contacts.length,
                    itemBuilder: (_, i) =>
                        _ContactCard(contact: state.contacts[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext ctx) {
    // Clear previous input
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _relationCtrl.clear();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddContactSheet(
          nameCtrl:     _nameCtrl,
          phoneCtrl:    _phoneCtrl,
          relationCtrl: _relationCtrl,
        ),
      ),
    );
  }
}

// ─── Helpline tile ────────────────────────────────────────────────────────────
class _HelplineTile extends StatelessWidget {
  final String emoji, number, label;
  final Color color;

  const _HelplineTile({
    required this.emoji,
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.mediumImpact();
          PhoneCallService.call(context, number, label: label);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(number,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: color,
                      letterSpacing: -0.5)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9,
                      color: DesignTokens.textMuted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Personal contact card ────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    final initials = contact.name.trim().split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: contact.isPrimary
              ? DesignTokens.primary.withValues(alpha: 0.4)
              : DesignTokens.border,
        ),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DesignTokens.primary, DesignTokens.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17)),
          ),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(contact.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: DesignTokens.textStrong)),
                ),
                if (contact.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryContainer,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text('⭐ Primary',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.primaryDark)),
                  ),
              ]),
              const SizedBox(height: 3),
              Text(contact.phoneNumber,
                  style: const TextStyle(
                      color: DesignTokens.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              if (contact.relation.isNotEmpty)
                Text(contact.relation,
                    style: const TextStyle(
                        color: DesignTokens.textSubtle, fontSize: 11)),
            ],
          ),
        ),

        // Action buttons
        const SizedBox(width: 8),
        Row(children: [
          _ActionBtn(
            icon: Icons.call_rounded,
            tooltip: 'Call',
            bg: DesignTokens.successContainer,
            iconColor: DesignTokens.success,
            onTap: () {
              HapticFeedback.mediumImpact();
              PhoneCallService.call(context, contact.phoneNumber,
                  label: contact.name);
            },
          ),
          const SizedBox(width: 6),
          _ActionBtn(
            icon: Icons.message_rounded,
            tooltip: 'SMS',
            bg: DesignTokens.secondaryContainer,
            iconColor: DesignTokens.secondary,
            onTap: () {
              HapticFeedback.lightImpact();
              PhoneCallService.sms(
                context,
                contact.phoneNumber,
                body: '🚨 Emergency! I need help. Please call me immediately.',
              );
            },
          ),
        ]),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color bg, iconColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyContacts extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyContacts({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👥', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 14),
            const Text('No personal contacts saved',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: DesignTokens.textStrong)),
            const SizedBox(height: 6),
            const Text(
              'Add family or friends who should be\nalerted when you send an SOS.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: DesignTokens.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Contact'),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add-contact bottom sheet ─────────────────────────────────────────────────
class _AddContactSheet extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController relationCtrl;

  const _AddContactSheet({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.relationCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: DesignTokens.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Row(children: [
            Text('➕', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Add Emergency Contact',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong)),
          ]),
          const SizedBox(height: 16),
          _SheetField(
              controller: nameCtrl, emoji: '👤', hint: 'Full Name'),
          const SizedBox(height: 10),
          _SheetField(
              controller: phoneCtrl,
              emoji: '📞',
              hint: 'Phone Number',
              isPhone: true),
          const SizedBox(height: 10),
          _SheetField(
              controller: relationCtrl,
              emoji: '🤝',
              hint: 'Relationship (e.g. Wife, Father)'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                // TODO: wire to EmergencyController.createContact when auth ready
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Row(children: [
                    Text('✅', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Text('Contact saved!',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  backgroundColor: DesignTokens.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Contact',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String emoji, hint;
  final bool isPhone;

  const _SheetField({
    required this.controller,
    required this.emoji,
    required this.hint,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: DesignTokens.textSubtle, fontSize: 13),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
