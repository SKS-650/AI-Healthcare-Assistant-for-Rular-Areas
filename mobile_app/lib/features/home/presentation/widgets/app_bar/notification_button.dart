import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: DesignTokens.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: DesignTokens.primary.withValues(alpha: 0.25)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: const Icon(Icons.notifications_outlined,
                  size: 20, color: DesignTokens.primaryDark),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 9,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: DesignTokens.danger,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
