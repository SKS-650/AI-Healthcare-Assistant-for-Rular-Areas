import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class NearbyHealthcarePage extends StatefulWidget {
  const NearbyHealthcarePage({super.key});

  @override
  State<NearbyHealthcarePage> createState() => _NearbyHealthcarePageState();
}

class _NearbyHealthcarePageState extends State<NearbyHealthcarePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _selectedFilter = 0;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('🗺', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Nearby Healthcare',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: DesignTokens.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list_rounded,
                  color: DesignTokens.primaryDark, size: 20),
              onPressed: () {},
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: DesignTokens.primary,
          unselectedLabelColor: DesignTokens.textMuted,
          indicatorColor: DesignTokens.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: '🏥 Hospitals'),
            Tab(text: '💊 Pharmacies'),
            Tab(text: '🩺 Clinics'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DesignTokens.border),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search hospitals, clinics...',
                  hintStyle: const TextStyle(
                      color: DesignTokens.textSubtle, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: DesignTokens.primary, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Distance filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _distanceFilters.asMap().entries.map((e) {
                  final selected = _selectedFilter == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  DesignTokens.primary,
                                  DesignTokens.primaryDark
                                ],
                              )
                            : null,
                        color: selected ? null : DesignTokens.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? DesignTokens.primary
                              : DesignTokens.border,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : DesignTokens.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // List
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: const [
                _FacilitiesList(facilities: _hospitals),
                _FacilitiesList(facilities: _pharmacies),
                _FacilitiesList(facilities: _clinics),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilitiesList extends StatelessWidget {
  final List<_HealthFacility> facilities;
  const _FacilitiesList({required this.facilities});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: facilities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _FacilityCard(facility: facilities[i]),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final _HealthFacility facility;
  const _FacilityCard({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DesignTokens.border),
        boxShadow: [
          BoxShadow(
            color: facility.color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        facility.color,
                        facility.color.withValues(alpha: 0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: facility.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(facility.emoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              facility.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: DesignTokens.textStrong,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (facility.isOpen)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: DesignTokens.successContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Open',
                                  style: TextStyle(
                                      color: DesignTokens.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: DesignTokens.dangerContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Closed',
                                  style: TextStyle(
                                      color: DesignTokens.danger,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: DesignTokens.textMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              facility.address,
                              style: const TextStyle(
                                color: DesignTokens.textMuted,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.near_me_rounded,
                            label: '${facility.distance} km',
                            color: facility.color,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.star_rounded,
                            label: '${facility.rating}',
                            color: DesignTokens.yellow,
                          ),
                          const SizedBox(width: 8),
                          if (facility.is24h)
                            const _InfoChip(
                              icon: Icons.access_time_rounded,
                              label: '24/7',
                              color: DesignTokens.green,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HealthFacility {
  final String name, address, emoji;
  final double distance, rating;
  final bool isOpen, is24h;
  final Color color;

  const _HealthFacility({
    required this.name,
    required this.address,
    required this.emoji,
    required this.distance,
    required this.rating,
    required this.isOpen,
    required this.is24h,
    required this.color,
  });
}

const _distanceFilters = ['All', '< 1 km', '1–5 km', '5–10 km', '> 10 km'];

const _hospitals = [
  _HealthFacility(
    name: 'District Government Hospital',
    address: 'Main Road, District Center',
    emoji: '🏥',
    distance: 0.8,
    rating: 4.2,
    isOpen: true,
    is24h: true,
    color: Color(0xFF4F94FF),
  ),
  _HealthFacility(
    name: 'Community Health Center',
    address: 'Village Square, Ward 3',
    emoji: '🏥',
    distance: 2.4,
    rating: 3.9,
    isOpen: true,
    is24h: false,
    color: Color(0xFF2ECC8B),
  ),
  _HealthFacility(
    name: 'Primary Health Center',
    address: 'Near Bus Stand, Village A',
    emoji: '🏥',
    distance: 4.1,
    rating: 3.7,
    isOpen: false,
    is24h: false,
    color: Color(0xFFFF7B3D),
  ),
  _HealthFacility(
    name: 'Rural Medical Clinic',
    address: 'Tribal Area, Block B',
    emoji: '🏥',
    distance: 6.8,
    rating: 4.0,
    isOpen: true,
    is24h: true,
    color: Color(0xFF926EFF),
  ),
];

const _pharmacies = [
  _HealthFacility(
    name: 'Jan Aushadhi Kendra',
    address: 'Market Road, Center',
    emoji: '💊',
    distance: 0.5,
    rating: 4.5,
    isOpen: true,
    is24h: false,
    color: Color(0xFF2ECC8B),
  ),
  _HealthFacility(
    name: 'Village Medical Store',
    address: 'Near Primary School',
    emoji: '💊',
    distance: 1.2,
    rating: 4.1,
    isOpen: true,
    is24h: false,
    color: Color(0xFF18C8C8),
  ),
  _HealthFacility(
    name: '24hr Pharmacy',
    address: 'Highway Junction',
    emoji: '💊',
    distance: 3.6,
    rating: 4.3,
    isOpen: true,
    is24h: true,
    color: Color(0xFFFF5E9E),
  ),
];

const _clinics = [
  _HealthFacility(
    name: 'Dr. Sharma General Clinic',
    address: 'Old Town, Near Temple',
    emoji: '🩺',
    distance: 0.9,
    rating: 4.6,
    isOpen: true,
    is24h: false,
    color: Color(0xFF926EFF),
  ),
  _HealthFacility(
    name: 'ASHA Community Clinic',
    address: 'Panchayat Building, Ward 5',
    emoji: '🩺',
    distance: 1.8,
    rating: 4.0,
    isOpen: false,
    is24h: false,
    color: Color(0xFFFFB829),
  ),
  _HealthFacility(
    name: 'Anganwadi Health Post',
    address: 'Women & Child Center',
    emoji: '🩺',
    distance: 2.3,
    rating: 3.8,
    isOpen: true,
    is24h: false,
    color: Color(0xFFFF5E9E),
  ),
];
