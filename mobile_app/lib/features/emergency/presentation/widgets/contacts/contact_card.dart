import 'package:flutter/material.dart';

import '../../../domain/entities/emergency_contact.dart';
import 'emergency_contact_tile.dart';

class ContactCard extends StatelessWidget {
  final EmergencyContact contact;

  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: EmergencyContactTile(contact: contact),
    );
  }
}
