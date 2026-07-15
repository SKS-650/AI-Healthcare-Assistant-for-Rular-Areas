import 'package:flutter/material.dart';
import '../../data/datasources/symptom_dummy_data.dart';

class SymptomSelectionPage extends StatefulWidget {
  final List<String> initialSymptoms;
  const SymptomSelectionPage({super.key, this.initialSymptoms = const []});

  @override
  State<SymptomSelectionPage> createState() => _SymptomSelectionPageState();
}

class _SymptomSelectionPageState extends State<SymptomSelectionPage>
    with SingleTickerProviderStateMixin {
  late List<String> _selected;
  String _query = '';
  String _activeCategory = 'All';
  late TabController _tabCtrl;

  static const _primary = Color(0xFF6C63FF);
  static const _bg = Color(0xFFF8F7FF);

  // All categories derived from the data
  late final List<String> _categories;
  late final Map<String, List<Map<String, dynamic>>> _categorized;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSymptoms);
    _categorized = _buildCategorized();
    _categories = ['All', ..._categorized.keys.toList()..sort()];
    _tabCtrl = TabController(length: _categories.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeCategory = _categories[_tabCtrl.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _buildCategorized() {
    const all = SymptomDummyData.allSymptomsFull;
    final map = <String, List<Map<String, dynamic>>>{};
    for (final s in all) {
      final cat = s['category'] as String;
      map.putIfAbsent(cat, () => []).add(s);
    }
    // Sort within each category
    for (final cat in map.keys) {
      map[cat]!.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }
    return map;
  }

  List<Map<String, dynamic>> get _filtered {
    final allItems = _activeCategory == 'All'
        ? SymptomDummyData.allSymptomsFull
        : (_categorized[_activeCategory] ?? []);
    if (_query.isEmpty) return allItems;
    final q = _query.toLowerCase();
    return allItems.where((s) {
      final name = (s['name'] as String).toLowerCase();
      final display = (s['display'] as String).toLowerCase();
      return name.contains(q) || display.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryTabs(),
          _buildSelectedBanner(),
          Expanded(child: _buildSymptomGrid(filtered)),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, Color(0xFF8B83FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context, _selected),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Symptoms', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('230+ medical symptoms available', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              if (_selected.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _selected.clear()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('Clear (${_selected.length})', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Search symptoms (e.g. fever, cough, headache)...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _primary, size: 22),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => setState(() => _query = ''),
                )
              : null,
          filled: true,
          fillColor: _bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        labelColor: _primary,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: _primary, width: 3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
        ),
        padding: const EdgeInsets.only(left: 8),
        tabAlignment: TabAlignment.start,
        tabs: _categories.map((c) {
          final count = c == 'All'
              ? SymptomDummyData.allSymptomsFull.length
              : (_categorized[c]?.length ?? 0);
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _activeCategory == c ? _primary.withValues(alpha: 0.15) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count',
                      style: TextStyle(fontSize: 10, color: _activeCategory == c ? _primary : Colors.grey.shade500, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedBanner() {
    if (_selected.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: _primary.withValues(alpha: 0.06),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(20)),
              child: Text('${_selected.length}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            ..._selected.map((s) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_toDisplay(s), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _selected.remove(s)),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                  ),
                ]),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomGrid(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No symptoms found for "$_query"', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            const SizedBox(height: 6),
            Text('Try a different keyword', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        final modelName = item['name'] as String;
        final display = item['display'] as String;
        final category = item['category'] as String;
        final icon = item['icon'] as IconData;
        final catColor = _categoryColor(category);
        final isSelected = _selected.contains(modelName);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? _primary.withValues(alpha: 0.06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _primary.withValues(alpha: 0.4) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _primary.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? _primary.withValues(alpha: 0.15) : catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isSelected ? _primary : catColor, size: 22),
              ),
              title: Text(
                display,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF333360) : const Color(0xFF555580),
                ),
              ),
              subtitle: Text(
                category,
                style: TextStyle(fontSize: 11, color: isSelected ? _primary.withValues(alpha: 0.7) : Colors.grey.shade400),
              ),
              trailing: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected ? _primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? _primary : Colors.grey.shade300, width: 2),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : null,
              ),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selected.remove(modelName);
                  } else {
                    _selected.add(modelName);
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: ElevatedButton(
        onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: Colors.grey.shade200,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              _selected.isEmpty
                  ? 'Select at least one symptom'
                  : 'Confirm ${_selected.length} Symptom${_selected.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: _selected.isEmpty ? Colors.grey.shade400 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toDisplay(String modelName) {
    return modelName.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  Color _categoryColor(String category) {
    const map = {
      'General': Color(0xFF6C63FF),
      'Respiratory': Color(0xFF48CAE4),
      'Cardiovascular': Color(0xFFE63946),
      'Neurological': Color(0xFF9B5DE5),
      'Digestive': Color(0xFFFF9F1C),
      'Musculoskeletal': Color(0xFF06D6A0),
      'Skin': Color(0xFFFF6B9D),
      'ENT': Color(0xFF4CC9F0),
      'Eyes': Color(0xFF7209B7),
      'Urinary': Color(0xFF4361EE),
      'Mental Health': Color(0xFF3A86FF),
      'Reproductive': Color(0xFFFF477E),
      'Immune': Color(0xFF2EC4B6),
    };
    return map[category] ?? const Color(0xFF6C63FF);
  }
}
