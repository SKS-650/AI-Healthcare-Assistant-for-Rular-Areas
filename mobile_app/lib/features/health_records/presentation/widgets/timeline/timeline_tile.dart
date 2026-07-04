import 'package:flutter/material.dart';

import '../../../domain/entities/medical_timeline.dart';
import 'timeline_card.dart';
import 'timeline_connector.dart';

class MedicalTimelineTile extends StatelessWidget {
  final MedicalTimeline item;
  final bool isLast;

  const MedicalTimelineTile({
    super.key,
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 32, child: TimelineConnector(isLast: isLast)),
          Expanded(child: TimelineCard(item: item)),
        ],
      ),
    );
  }
}
