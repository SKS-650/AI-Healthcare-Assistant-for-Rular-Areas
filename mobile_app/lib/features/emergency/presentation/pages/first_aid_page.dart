import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../providers/emergency_provider.dart';
import '../widgets/first_aid/first_aid_card.dart';

class FirstAidPage extends ConsumerStatefulWidget {
  const FirstAidPage({super.key});

  @override
  ConsumerState<FirstAidPage> createState() => _FirstAidPageState();
}

class _FirstAidPageState extends ConsumerState<FirstAidPage> {
  String _selectedCategory = 'All';

  static const _categories = [
    ('🏥', 'All'),
    ('❤️', 'Cardiac'),
    ('🧠', 'Neurological'),
    ('🩸', 'Bleeding'),
    ('🌡️', 'Fever'),
    ('🐍', 'Bites'),
    ('🤕', 'Injury'),
  ];

  // Full built-in first-aid guides
  static const _builtinGuides = [
    _GuideData(
      emoji: '❤️',
      title: 'Chest Pain / Heart Attack',
      category: 'Cardiac',
      urgency: '🔴 CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        '📞 Call 102 (ambulance) immediately',
        '🛋️ Have the person sit or lie down comfortably',
        '💊 Give aspirin (325 mg) if available and not allergic',
        '🤚 Loosen tight clothing around neck and chest',
        '👀 Monitor breathing and pulse continuously',
        '🫀 Begin CPR if person becomes unresponsive and stops breathing',
      ],
      doNotSteps: [
        'Do NOT give food or water',
        'Do NOT let the person exert themselves',
        'Do NOT drive to hospital alone — wait for ambulance',
      ],
      callToAction: 'Call 102 immediately. Every minute counts.',
    ),
    _GuideData(
      emoji: '🧠',
      title: 'Stroke — Use FAST',
      category: 'Neurological',
      urgency: '🔴 CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        '⏰ Note the time symptoms started — critical for treatment',
        '😶 F — Face: Ask to smile. Is one side drooping?',
        '💪 A — Arms: Ask to raise both. Does one drift down?',
        '🗣️ S — Speech: Ask to repeat a phrase. Is it slurred?',
        '📞 T — Time: If yes to ANY of the above, call 102 NOW',
        '🧑‍⚕️ Keep the person calm and still until help arrives',
      ],
      doNotSteps: [
        'Do NOT give food, water or any medication',
        'Do NOT let the person sleep it off',
        'Do NOT wait for symptoms to improve on their own',
      ],
      callToAction: 'Call 102 NOW. Treatment is most effective within 3 hours.',
    ),
    _GuideData(
      emoji: '🩸',
      title: 'Severe Bleeding',
      category: 'Bleeding',
      urgency: '🟠 URGENT',
      urgencyColor: Color(0xFFF97316),
      steps: [
        '🧤 Wear gloves if available to protect yourself',
        '🤚 Apply firm direct pressure to the wound',
        '🧣 Use a clean cloth or bandage — do not remove if soaked, add more on top',
        '⬆️ Elevate the injured limb above heart level if possible',
        '🩹 For limb bleeding that won\'t stop: apply tourniquet 5–7 cm above wound',
        '📞 Seek emergency care immediately',
      ],
      doNotSteps: [
        'Do NOT remove embedded objects — stabilise them',
        'Do NOT apply tourniquet to neck, chest or abdomen',
      ],
      callToAction: 'Call 102. Severe bleeding causes shock within minutes.',
    ),
    _GuideData(
      emoji: '🌡️',
      title: 'High Fever / Seizure',
      category: 'Fever',
      urgency: '🟡 MODERATE',
      urgencyColor: DesignTokens.warning,
      steps: [
        '🌡️ Measure temperature accurately with a thermometer',
        '💊 Give paracetamol at correct dose for age and weight',
        '🧊 Apply cool (not cold) damp cloth to forehead and armpits',
        '💧 Ensure adequate fluid intake — water or oral rehydration solution',
        '👕 Remove excessive clothing and blankets',
        '🏥 Seek care if fever exceeds 39.5°C or seizures occur',
      ],
      doNotSteps: [
        'Do NOT use ice-cold water baths — causes shivering',
        'Do NOT give aspirin to children under 16',
        'Do NOT put anything in the mouth during a seizure',
      ],
      callToAction: 'Call 102 if fever exceeds 39.5°C, seizure occurs, or child is under 3 months.',
    ),
    _GuideData(
      emoji: '🐍',
      title: 'Snakebite / Animal Bite',
      category: 'Bites',
      urgency: '🔴 CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        '🛑 Move the person away from the snake immediately',
        '🧘 Keep the person calm and still to slow venom spread',
        '📉 Keep the bitten limb below heart level',
        '🧼 Wash gently with soap and water',
        '❌ Do NOT cut, suck or apply tourniquet',
        '📞 Call poison control or go to hospital with antivenom urgently',
      ],
      doNotSteps: [
        'Do NOT cut the wound or try to suck out venom',
        'Do NOT apply a tourniquet or ice',
        'Do NOT give aspirin or ibuprofen — they increase bleeding',
      ],
      callToAction: 'Call 102. Antivenom must be given within 4–6 hours.',
    ),
    _GuideData(
      emoji: '☠️',
      title: 'Poisoning / Overdose',
      category: 'Injury',
      urgency: '🔴 CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        '📞 Call 102 or Poison Control (1800-116-117) immediately',
        '🧴 Identify the substance if possible — bring container to hospital',
        '❌ Do NOT induce vomiting unless specifically told to',
        '💨 If inhaled: move person to fresh air immediately',
        '🛁 If on skin: remove clothing and flush with water 20 minutes',
        '👀 Monitor breathing and consciousness',
      ],
      doNotSteps: [
        'Do NOT induce vomiting without medical guidance',
        'Do NOT give milk, water or any food',
        'Do NOT leave the person alone',
      ],
      callToAction: 'Call Poison Control 1800-116-117 or 102 immediately.',
    ),
    _GuideData(
      emoji: '😵',
      title: 'Loss of Consciousness',
      category: 'Neurological',
      urgency: '🔴 CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        '📞 Call 102 immediately',
        '👋 Check responsiveness: tap shoulders, shout name',
        '👁️ Check breathing: look, listen and feel',
        '🔄 If breathing: place in recovery position on side',
        '🫀 If NOT breathing: begin CPR — 30 compressions, 2 rescue breaths',
        '⏱️ Continue CPR until ambulance arrives',
      ],
      doNotSteps: [
        'Do NOT leave the person alone',
        'Do NOT place a pillow under the head',
        'Do NOT give food or water',
      ],
      callToAction: 'Call 102 immediately and start CPR if not breathing.',
    ),
    _GuideData(
      emoji: '😮',
      title: 'Choking',
      category: 'Injury',
      urgency: '🔴 CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        '❓ Ask loudly: "Are you choking?"',
        '🚫 If person cannot speak, cough or breathe — act now',
        '👋 Give 5 firm back blows between shoulder blades with heel of hand',
        '🤼 Give 5 abdominal thrusts (Heimlich): arms around waist, push upward',
        '🔁 Alternate 5 back blows and 5 abdominal thrusts',
        '📞 If unconscious: begin CPR and call 102',
      ],
      doNotSteps: [
        'Do NOT perform blind finger sweeps in the mouth',
        'Do NOT slap a person who is still coughing effectively',
      ],
      callToAction: 'Call 102 if choking is not resolved within 2 minutes.',
    ),
  ];

  List<_GuideData> get _filteredGuides => _selectedCategory == 'All'
      ? _builtinGuides
      : _builtinGuides
          .where((g) => g.category == _selectedCategory)
          .toList();

  @override
  Widget build(BuildContext context) {
    final state      = ref.watch(emergencyControllerProvider);
    final useBuiltin = state.firstAidGuides.isEmpty;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(children: [
          Text('🩹', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text('First Aid Guides',
              style: TextStyle(
                  color: DesignTokens.textStrong, fontWeight: FontWeight.w700)),
        ]),
        actions: [
          // Instant 102 dial from first-aid page
          TextButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              PhoneCallService.call(context, '102', label: 'Ambulance');
            },
            icon: const Icon(Icons.call_rounded,
                size: 16, color: DesignTokens.danger),
            label: const Text('Call 102',
                style: TextStyle(
                    color: DesignTokens.danger,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ),
        ],
      ),
      body: Column(children: [
        // ── Category filter chips ──────────────────────────────────────
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat      = _categories[i];
              final selected = _selectedCategory == cat.$2;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: selected ? DesignTokens.primary : DesignTokens.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected
                            ? DesignTokens.primary
                            : DesignTokens.border),
                  ),
                  child: Row(children: [
                    Text(cat.$1, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(cat.$2,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : DesignTokens.textStrong)),
                  ]),
                ),
              );
            },
          ),
        ),

        // ── Warning + 102 strip ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DesignTokens.dangerContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Text('⚠️', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'These are general guidelines. For life-threatening emergencies call 102 immediately.',
                  style: TextStyle(
                      color: DesignTokens.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  PhoneCallService.call(context, '102', label: 'Ambulance');
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: DesignTokens.danger,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.call_rounded, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text('102',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900)),
                  ]),
                ),
              ),
            ]),
          ),
        ),

        // ── Guides list ────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(emergencyControllerProvider.notifier).refreshFirstAid(),
            child: useBuiltin
                ? (_filteredGuides.isEmpty
                    ? const Center(
                        child: Text('No guides in this category.',
                            style: TextStyle(color: DesignTokens.textMuted)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: _filteredGuides.length,
                        itemBuilder: (_, i) =>
                            _GuideCard(guide: _filteredGuides[i]),
                      ))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: state.firstAidGuides.length,
                    itemBuilder: (_, i) =>
                        FirstAidCard(guide: state.firstAidGuides[i]),
                  ),
          ),
        ),
      ]),
    );
  }
}

// ─── Built-in guide card ──────────────────────────────────────────────────────
class _GuideCard extends StatefulWidget {
  final _GuideData guide;
  const _GuideCard({required this.guide});

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded  = false;
  bool _showDonts = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.guide;

    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() {
            _expanded = !_expanded;
            if (!_expanded) _showDonts = false;
          }),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ─────────────────────────────────────────
                Row(children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: g.urgencyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child: Text(g.emoji,
                            style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(g.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: DesignTokens.textStrong)),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: g.urgencyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(g.urgency,
                            style: TextStyle(
                                color: g.urgencyColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: DesignTokens.textMuted),
                  ),
                ]),

                // ── Expanded content ───────────────────────────────────
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: _expanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: DesignTokens.borderMuted),
                      const SizedBox(height: 12),

                      // Steps
                      ...g.steps.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: DesignTokens.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: DesignTokens.primaryDark)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(e.value,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: DesignTokens.textStrong,
                                    height: 1.4)),
                          ),
                        ]),
                      )),

                      // What NOT to do (collapsible)
                      if (g.doNotSteps.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showDonts = !_showDonts),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: [
                              const Text('🚫',
                                  style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('What NOT to do',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFFDC2626))),
                              ),
                              Icon(
                                _showDonts
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: const Color(0xFFDC2626),
                              ),
                            ]),
                          ),
                        ),
                        if (_showDonts) ...[
                          const SizedBox(height: 8),
                          ...g.doNotSteps.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              const Text('❌',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(s,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF991B1B),
                                        height: 1.4)),
                              ),
                            ]),
                          )),
                        ],
                      ],

                      // Call-to-action
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          PhoneCallService.call(context, '102',
                              label: 'Ambulance');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF059669)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.call_rounded,
                                size: 14, color: Color(0xFF059669)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(g.callToAction,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: Color(0xFF059669))),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                size: 14, color: Color(0xFF059669)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Data class for built-in guides ──────────────────────────────────────────
class _GuideData {
  final String emoji;
  final String title;
  final String category;
  final String urgency;
  final Color urgencyColor;
  final List<String> steps;
  final List<String> doNotSteps;
  final String callToAction;

  const _GuideData({
    required this.emoji,
    required this.title,
    required this.category,
    required this.urgency,
    required this.urgencyColor,
    required this.steps,
    this.doNotSteps = const [],
    this.callToAction = 'Call 102 for emergencies.',
  });
}
