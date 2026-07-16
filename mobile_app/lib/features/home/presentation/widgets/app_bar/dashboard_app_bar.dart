import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import 'greeting_widget.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: DesignTokens.background,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: const GreetingWidget(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
