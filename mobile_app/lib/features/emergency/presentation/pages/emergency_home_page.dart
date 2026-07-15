import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controllers/emergency_state.dart';
import '../providers/emergency_provider.dart';
import '../widgets/ambulances/ambulance_preview.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/hospitals/hospital_preview.dart';
import 'emergency_assessment_page.dart';
import 'emergency_contacts_page.dart';
import 'emergency_detection_page.dart';
import 'emergency_history_page.dart';
import 'first_aid_page.dart';
import 'nearby_ambulances_page.dart';
import 'nearby_hospitals_page.dart';
import 'sos_page.dart';

class EmergencyHomePage extends ConsumerWidget {
  const EmergencyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF1F2),
        body: switch (state.status) {
          EmergencyStatus.initial || EmergencyStatus.loading =>
            const EmergencyLoadingWidget(),
          _ => RefreshIndicator(
            color: DesignTokens.danger,
            onRefresh: () =>
                ref.read(emergencyControllerProvider.notifier).load(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _EmergencyHeader()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── AI Assessment Banner (new) ────────────────────
                        _AssessmentBanner(
                          onTap: () {
                            // Reset any previous assessment state first
                            ref
                                .read(assessmentControllerProvider.notifier)
                                .resetAssessment();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const EmergencyAssessmentPage(),
                            ));
                          },
                        ),
                        const SizedBox(height: 12),

                        // ── SOS Big Button ────────────────────────────────
                        _SosBigButton(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SosPage()),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Action Cards Grid ─────────────────────────────
                        _ActionGrid(state: state),

                        // ── Nearby hospitals ──────────────────────────────
                        _SectionHeader(
                          emoji: '🏥',
                          title: 'Nearby Hospitals',
                          onSeeAll: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NearbyHospitalsPage(),
                            ),
                          ),
                        ),
                        HospitalPreview(hospitals: state.hospitals),

                        // ── Nearby ambulances ─────────────────────────────
                        _SectionHeader(
                          emoji: '🚑',
                          title: 'Nearby Ambulances',
                          onSeeAll: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NearbyAmbulancesPage(),
                            ),
                          ),
                        ),
                        AmbulancePreview(ambulances: state.ambulances),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}

// ─── AI Assessment Banner ─────────────────────────────────────────────────────
class _AssessmentBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AssessmentBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Center(
              child: Text('🩺', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Emergency Assessment',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text('Describe symptoms → get risk score + first aid',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Start',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 11),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _EmergencyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🚨 Emergency Support',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3)),
            Text('Fast help when you need it most',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }
}

// ─── SOS Big Button ───────────────────────────────────────────────────────────
class _SosBigButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SosBigButton({required this.onTap});

  @override
  State<_SosBigButton> createState() => _SosBigButtonState();
}

class _SosBigButtonState extends State<_SosBigButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.danger
                      .withValues(alpha: 0.3 + _pulse.value * 0.2),
                  blurRadius: 20 + _pulse.value * 15,
                  spreadRadius: _pulse.value * 4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 2),
                ),
                child: const Center(
                  child: Text('🆘', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Send SOS Alert',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3)),
                  SizedBox(height: 4),
                  Text('Alert emergency contacts & find nearby help instantly',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13, height: 1.3)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white70, size: 24),
            ]),
          );
        },
      ),
    );
  }
}

// ─── Action Grid ──────────────────────────────────────────────────────────────
class _ActionGrid extends StatelessWidget {
  final EmergencyState state;
  const _ActionGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        emoji: '🔍',
        title: 'Detect Emergency',
        subtitle: 'Describe & get guidance',
        bgColor: const Color(0xFFFFF7ED),
        borderColor: const Color(0xFFFED7AA),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmergencyDetectionPage()),
        ),
      ),
      _ActionItem(
        emoji: '🩹',
        title: 'First Aid',
        subtitle: 'Step-by-step guides',
        bgColor: const Color(0xFFF0FDF4),
        borderColor: const Color(0xFFBBF7D0),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FirstAidPage()),
        ),
      ),
      _ActionItem(
        emoji: '📞',
        title: 'Contacts',
        subtitle: '${state.contacts.length} saved',
        bgColor: const Color(0xFFEFF6FF),
        borderColor: const Color(0xFFBFDBFE),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmergencyContactsPage()),
        ),
      ),
      _ActionItem(
        emoji: '📋',
        title: 'History',
        subtitle: '${state.history.length} events',
        bgColor: const Color(0xFFF5F3FF),
        borderColor: const Color(0xFFDDD6FE),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmergencyHistoryPage()),
        ),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: actions.map((a) => _ActionTile(item: a)).toList(),
    );
  }
}

// ─── Action tile ──────────────────────────────────────────────────────────────
class _ActionItem {
  final String emoji, title, subtitle;
  final Color bgColor, borderColor;
  final VoidCallback onTap;
  const _ActionItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;
  const _ActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.borderColor),
          ),
          child: Row(children: [
            Text(item.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: DesignTokens.textStrong)),
                  Text(item.subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: DesignTokens.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: DesignTokens.textSubtle),
          ]),
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String emoji, title;
  final VoidCallback onSeeAll;
  const _SectionHeader(
      {required this.emoji, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 17)),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong,
                    letterSpacing: -0.3)),
          ]),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DesignTokens.dangerContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('See all',
                  style: TextStyle(
                      color: DesignTokens.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
