import 'package:flutter/material.dart';

import 'app_icons.dart';

class AppIllustrations {
  const AppIllustrations._();

  static const String hospitalEmoji = '🏥';
  static const String medicineEmoji = '💊';
  static const String emergencyEmoji = '🚨';
  static const String locationEmoji = '📍';
  static const String recordsEmoji = '📋';
  static const String assistantEmoji = '🤖';

  static IconData forEmptyState(String type) {
    return switch (type) {
      'hospital' => AppIcons.hospital,
      'pharmacy' => AppIcons.pharmacy,
      'emergency' => AppIcons.emergency,
      'records' => AppIcons.records,
      'location' => AppIcons.location,
      _ => AppIcons.info,
    };
  }
}
