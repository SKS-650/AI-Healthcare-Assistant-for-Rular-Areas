import 'package:flutter/material.dart';

class MessageTime extends StatelessWidget {
  final DateTime time;
  final bool light;

  const MessageTime({super.key, required this.time, this.light = false});

  @override
  Widget build(BuildContext context) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final formatted = '$hour:$minute';
    return Text(
      formatted,
      style: TextStyle(
        fontSize: 10,
        color: light ? Colors.white60 : Colors.grey.shade500,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
