import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/emergency_contact.dart';
import '../providers/emergency_provider.dart';

class EmergencyContactsPage extends ConsumerWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('ðŸ“ž', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Emergency Contacts'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () => _showAddContactSheet(context),
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
        children: [
          // Tip banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignTokens.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('ðŸ’¡', style: TextStyle(fontSize: 14)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These contacts are notified automatically when you send an SOS alert.',
                    style: TextStyle(
                      color: DesignTokens.primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // National helplines row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: const [
                Text('ðŸ›ï¸', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                Text('National Helplines',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: DesignTokens.textStrong)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _HelplineBtn(emoji: 'ðŸš‘', num: '102', label: 'Ambulance'),
                const SizedBox(width: 8),
                _HelplineBtn(emoji: 'ðŸš“', num: '100', label: 'Police'),
                const SizedBox(width: 8),
                _HelplineBtn(emoji: 'ðŸ”¥', num: '101', label: 'Fire'),
                const SizedBox(width: 8),
                _HelplineBtn(emoji: 'ðŸ¥', num: '104', label: 'Health'),
              ],
            ),
          ),

          // Personal contacts header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('ðŸ‘¤', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text('Personal Contacts',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: DesignTokens.textStrong)),
                  ],
                ),
                Text('${state.contacts.length} saved',
                    style: const TextStyle(
                        color: DesignTokens.textMuted, fontSize: 12)),
              ],
            ),
          ),

          Expanded(
            child: state.contacts.isEmpty
                ? _EmptyContacts(onAdd: () => _showAddContactSheet(context))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: state.contacts.length,
                    itemBuilder: (ctx, i) =>
                        _ContactRow(contact: state.contacts[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddContactSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _AddContactSheet(),
      ),
    );
  }
}

class _HelplineBtn extends StatelessWidget {
  final String emoji;
  final String num;
  final String label;

  const _HelplineBtn(
      {required this.emoji, required this.num, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: DesignTokens.dangerContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: DesignTokens.danger.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(num,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: DesignTokens.danger)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9,
                      color: DesignTokens.textMuted,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final EmergencyContact contact;
  const _ContactRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    final initials = contact.name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: contact.isPrimary
              ? DesignTokens.primary.withValues(alpha: 0.3)
              : DesignTokens.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
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
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(contact.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: DesignTokens.textStrong)),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryContainer,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text('â­ Primary',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.primaryDark)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('ðŸ“ž ${contact.phoneNumber}',
                    style: const TextStyle(
                        color: DesignTokens.textMuted, fontSize: 12)),
                if (contact.relation.isNotEmpty)
                  Text('ðŸ¤ ${contact.relation}',
                      style: const TextStyle(
                          color: DesignTokens.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Row(
            children: [
              _CircleBtn(emoji: 'ðŸ“ž', bg: DesignTokens.successContainer),
              const SizedBox(width: 6),
              _CircleBtn(emoji: 'âœ‰ï¸', bg: DesignTokens.secondaryContainer),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final String emoji;
  final Color bg;
  const _CircleBtn({required this.emoji, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
    );
  }
}

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
            const Text('ðŸ‘¥', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 16),
            const Text('No emergency contacts',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: DesignTokens.textStrong)),
            const SizedBox(height: 6),
            const Text(
              'Add trusted family or friends\nto notify in an emergency.',
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

class _AddContactSheet extends StatelessWidget {
  const _AddContactSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Text('âž•', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Add Emergency Contact',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong)),
            ],
          ),
          const SizedBox(height: 16),
          _SheetField(emoji: 'ðŸ‘¤', hint: 'Full Name'),
          const SizedBox(height: 10),
          _SheetField(emoji: 'ðŸ“ž', hint: 'Phone Number', isPhone: true),
          const SizedBox(height: 10),
          _SheetField(emoji: 'ðŸ¤', hint: 'Relationship (e.g. Wife, Father)'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(children: [
                      Text('âœ…', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 8),
                      Text('Contact saved!'),
                    ]),
                    backgroundColor: DesignTokens.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
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
  final String emoji;
  final String hint;
  final bool isPhone;
  const _SheetField(
      {required this.emoji, required this.hint, this.isPhone = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.border),
      ),
      child: TextField(
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
