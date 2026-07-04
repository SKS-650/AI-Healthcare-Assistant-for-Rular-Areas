import 'package:flutter/material.dart';
import '../../../../shared/design_system/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/health_records_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/search/filter_bottom_sheet.dart';
import '../widgets/search/search_bar.dart';
import '../widgets/search/search_result_card.dart';
import 'report_detail_page.dart';

class SearchRecordsPage extends ConsumerStatefulWidget {
  const SearchRecordsPage({super.key});

  @override
  ConsumerState<SearchRecordsPage> createState() => _SearchRecordsPageState();
}

class _SearchRecordsPageState extends ConsumerState<SearchRecordsPage> {
  final _controller = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthRecordsControllerProvider);
    final results = _filter == 'All'
        ? state.searchResults
        : state.searchResults
              .where((record) => record.category == _filter)
              .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Search Records'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: const Icon(Icons.tune),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => FilterBottomSheet(
                filters: const [
                  'All',
                  'Consultation',
                  'Cardiology',
                  'Lab Report',
                ],
                selectedFilter: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          HealthRecordSearchBar(
            controller: _controller,
            onChanged: (value) {
              ref.read(healthRecordsControllerProvider.notifier).search(value);
            },
          ),
          Expanded(
            child: results.isEmpty
                ? const EmptyState(
                    title: 'No matching records',
                    message: 'Try a doctor name, category, condition, or tag.',
                    icon: Icons.manage_search,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final record = results[index];
                      return SearchResultCard(
                        record: record,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReportDetailPage(item: record),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
