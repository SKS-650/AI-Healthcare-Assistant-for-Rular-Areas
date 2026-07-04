import 'package:flutter/material.dart';

import '../design_system/app_icons.dart';
import 'app_text_field.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;
    return AppTextField(
      controller: controller,
      label: hint,
      prefixIcon: AppIcons.search,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      suffix: hasText
          ? IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close_rounded),
              onPressed: onClear,
            )
          : null,
    );
  }
}
