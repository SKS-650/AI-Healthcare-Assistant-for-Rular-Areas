import 'package:flutter/material.dart';

import '../../../domain/entities/emergency_contact.dart';

class EmergencyContactTile extends StatelessWidget {
  final EmergencyContact contact;

  const EmergencyContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(contact.name.characters.first.toUpperCase()),
      ),
      title: Text(contact.name),
      subtitle: Text('${contact.relation} • ${contact.phoneNumber}'),
      trailing: IconButton(
        tooltip: 'Call contact',
        onPressed: () {},
        icon: const Icon(Icons.call_rounded),
      ),
    );
  }
}
