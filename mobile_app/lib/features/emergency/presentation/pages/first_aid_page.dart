import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
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
    ('ðŸ¥', 'All'),
    ('ðŸ’”', 'Cardiac'),
    ('ðŸ§ ', 'Neurological'),
    ('ðŸ©¸', 'Bleeding'),
    ('ðŸŒ¡ï¸', 'Fever'),
    ('ðŸ', 'Bites'),
    ('ðŸ¤•', 'Injury'),
  ];

  // Built-in first aid guides shown when no data loaded
  static const _builtinGuides = [
    _GuideData(
      emoji: 'ðŸ’”',
      title: 'Chest Pain / Heart Attack',
      category: 'Cardiac',
      urgency: 'ðŸ”´ CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        'ðŸ“ž Call 102 (ambulance) immediately',
        'ðŸ›‹ï¸ Have the person sit or lie down comfortably',
        'ðŸ’Š Give aspirin if available and not allergic',
        'ðŸ¤š Loosen tight clothing around neck & chest',
        'ðŸ‘€ Monitor breathing and pulse',
        'ðŸ«€ Begin CPR if person becomes unresponsive',
      ],
    ),
    _GuideData(
      emoji: 'ðŸ§ ',
      title: 'Stroke (FAST)',
      category: 'Neurological',
      urgency: 'ðŸ”´ CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        'ðŸ˜¶ F â€” Face drooping: Ask to smile',
        'ðŸ’ª A â€” Arm weakness: Check both arms',
        'ðŸ—£ï¸ S â€” Speech difficulty: Ask to repeat phrase',
        'â° T â€” Time: Call 102 immediately',
        'ðŸ›‘ Do not give food, water or medicine',
        'ðŸ§‘â€âš•ï¸ Keep person calm until help arrives',
      ],
    ),
    _GuideData(
      emoji: 'ðŸ©¸',
      title: 'Severe Bleeding',
      category: 'Bleeding',
      urgency: 'ðŸŸ  URGENT',
      urgencyColor: Color(0xFFF97316),
      steps: [
        'ðŸ§¤ Wear gloves if available',
        'ðŸ¤š Apply firm direct pressure to the wound',
        'ðŸ§£ Use a clean cloth or bandage',
        'â¬†ï¸ Elevate the injured limb if possible',
        'ðŸ©¹ Do not remove the cloth if soaked â€” add more',
        'ðŸ“ž Seek emergency care immediately',
      ],
    ),
    _GuideData(
      emoji: 'ðŸŒ¡ï¸',
      title: 'High Fever',
      category: 'Fever',
      urgency: 'ðŸŸ¡ MODERATE',
      urgencyColor: DesignTokens.warning,
      steps: [
        'ðŸŒ¡ï¸ Measure temperature accurately',
        'ðŸ’§ Ensure adequate fluid intake',
        'ðŸ§Š Use cool damp cloth on forehead',
        'ðŸ’Š Give paracetamol if appropriate',
        'ðŸ‘• Remove excessive clothing',
        'ðŸ¥ Seek care if fever exceeds 39.5Â°C',
      ],
    ),
    _GuideData(
      emoji: 'ðŸ',
      title: 'Snake / Animal Bite',
      category: 'Bites',
      urgency: 'ðŸ”´ CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        'ðŸ›‘ Keep the person calm and still',
        'ðŸ”» Keep the bitten area below heart level',
        'ðŸ§¼ Wash with soap and water gently',
        'âŒ Do NOT cut, suck or apply tourniquet',
        'ðŸ“ž Call poison control or go to hospital',
        'ðŸ“¸ Photograph the snake if safely possible',
      ],
    ),
    _GuideData(
      emoji: 'ðŸ¤¢',
      title: 'Poisoning / Overdose',
      category: 'Injury',
      urgency: 'ðŸ”´ CRITICAL',
      urgencyColor: DesignTokens.danger,
      steps: [
        'ðŸ“ž Call 102 or poison control immediately',
        'ðŸ§´ Identify the substance if possible',
        'âŒ Do NOT induce vomiting unless instructed',
        'ðŸ’¨ Move to fresh air if inhaled',
        'ðŸ‘€ Monitor breathing and consciousness',
        'ðŸ¥ Bring the poison container to hospital',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emergencyControllerProvider);

    // Use built-in guides if no data from provider
    final useBuiltin = state.firstAidGuides.isEmpty;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('ðŸ©¹', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('First Aid Guides'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 50,
            color: DesignTokens.background,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat.$2;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? DesignTokens.primary
                          : DesignTokens.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? DesignTokens.primary
                            : DesignTokens.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(cat.$1, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          cat.$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : DesignTokens.textStrong,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Warning banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignTokens.dangerContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text('âš ï¸', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These are general guidelines. Call 102 for all life-threatening emergencies.',
                      style: TextStyle(
                        color: DesignTokens.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Guides list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(emergencyControllerProvider.notifier)
                  .refreshFirstAid(),
              child: useBuiltin
                  ? _BuiltinGuidesList(
                      guides: _builtinGuides
                          .where((g) =>
                              _selectedCategory == 'All' ||
                              g.category == _selectedCategory)
                          .toList(),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: state.firstAidGuides.length,
                      itemBuilder: (context, i) =>
                          FirstAidCard(guide: state.firstAidGuides[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuiltinGuidesList extends StatelessWidget {
  final List<_GuideData> guides;
  const _BuiltinGuidesList({required this.guides});

  @override
  Widget build(BuildContext context) {
    if (guides.isEmpty) {
      return const Center(
        child: Text('No guides in this category.', style: TextStyle(color: DesignTokens.textMuted)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: guides.length,
      itemBuilder: (context, i) => _GuideCard(guide: guides[i]),
    );
  }
}

class _GuideCard extends StatefulWidget {
  final _GuideData guide;
  const _GuideCard({required this.guide});

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
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
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.guide.urgencyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(widget.guide.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.guide.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: DesignTokens.textStrong,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.guide.urgencyColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.guide.urgency,
                              style: TextStyle(
                                color: widget.guide.urgencyColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: DesignTokens.textMuted,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _expanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: DesignTokens.borderMuted),
                      const SizedBox(height: 12),
                      ...widget.guide.steps.asMap().entries.map((e) {
                        return Padding(
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
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: DesignTokens.primaryDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: DesignTokens.textStrong,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

class _GuideData {
  final String emoji;
  final String title;
  final String category;
  final String urgency;
  final Color urgencyColor;
  final List<String> steps;

  const _GuideData({
    required this.emoji,
    required this.title,
    required this.category,
    required this.urgency,
    required this.urgencyColor,
    required this.steps,
  });
}
