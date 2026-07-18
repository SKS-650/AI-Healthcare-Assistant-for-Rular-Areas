import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../routing/route_names.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';

/// Emergency banner shown on the home dashboard.
/// The whole card navigates to EmergencyHomePage.
/// The "SOS" chip instantly dials 102.
class EmergencyCard extends StatelessWidget {
  const EmergencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4757), Color(0xFFFF7B3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.danger.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // decorative orb
          Positioned(
            right: -12,
            top: -12,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              // whole card → full emergency hub
              onTap: () =>
                  Navigator.of(context).pushNamed(RouteNames.emergency),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 15),
                child: Row(
                  children: [
                    // icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: const Center(
                          child:
                              Text('🚨', style: TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 14),

                    // text
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medical Emergency?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                letterSpacing: -0.2),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Tap for AI triage • SOS • 102',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // SOS chip — dials 102 directly, does NOT navigate
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        PhoneCallService.call(context, '102',
                            label: 'Ambulance');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.call_rounded,
                                size: 13, color: Color(0xFFFF4757)),
                            SizedBox(width: 4),
                            Text('102',
                                style: TextStyle(
                                    color: Color(0xFFFF4757),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
