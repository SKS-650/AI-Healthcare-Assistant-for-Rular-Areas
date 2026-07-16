import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme.dart';

/// A styled card wrapping a DataTable with search, filter and pagination.
class DataTableCard extends StatelessWidget {
  final String title;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool isLoading;
  final int totalRows;
  final int currentPage;
  final int pageSize;
  final ValueChanged<int>? onPageChanged;
  final Widget? searchBar;
  final List<Widget>? filters;
  final Widget? headerAction;

  const DataTableCard({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.totalRows = 0,
    this.currentPage = 1,
    this.pageSize = 20,
    this.onPageChanged,
    this.searchBar,
    this.filters,
    this.headerAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final totalPages = (totalRows / pageSize).ceil().clamp(1, 9999);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (headerAction != null) headerAction!,
              ],
            ),
          ),

          // ── Search + filters ─────────────────────────────────────────────
          if (searchBar != null || (filters != null && filters!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (searchBar != null) searchBar!,
                  if (filters != null) ...filters!,
                ],
              ),
            ),

          Divider(height: 1, color: borderColor),

          // ── Table ────────────────────────────────────────────────────────
          if (isLoading)
            _ShimmerTable(columns: columns.length)
          else if (rows.isEmpty)
            _EmptyState()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMaxHeight: 56,
                headingRowColor: WidgetStateProperty.all(
                  isDark
                      ? AppColors.darkSurface2
                      : AppColors.lightSurface2,
                ),
                border: TableBorder(
                  horizontalInside:
                      BorderSide(color: borderColor, width: 0.5),
                ),
                columns: columns,
                rows: rows,
              ),
            ),

          // ── Pagination ───────────────────────────────────────────────────
          if (totalPages > 1 || totalRows > 0) ...[
            Divider(height: 1, color: borderColor),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Showing ${((currentPage - 1) * pageSize) + 1}–'
                    '${(currentPage * pageSize).clamp(0, totalRows)} '
                    'of $totalRows',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const Spacer(),
                  _PaginationButtons(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: onPageChanged,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaginationButtons extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;

  const _PaginationButtons({
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PageBtn(
          icon: Icons.first_page_rounded,
          onTap: currentPage > 1 ? () => onPageChanged?.call(1) : null,
        ),
        _PageBtn(
          icon: Icons.chevron_left_rounded,
          onTap: currentPage > 1
              ? () => onPageChanged?.call(currentPage - 1)
              : null,
        ),
        const SizedBox(width: 4),
        Text('$currentPage / $totalPages',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        _PageBtn(
          icon: Icons.chevron_right_rounded,
          onTap: currentPage < totalPages
              ? () => onPageChanged?.call(currentPage + 1)
              : null,
        ),
        _PageBtn(
          icon: Icons.last_page_rounded,
          onTap: currentPage < totalPages
              ? () => onPageChanged?.call(totalPages)
              : null,
        ),
      ],
    );
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PageBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onTap,
        style: IconButton.styleFrom(
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
        ),
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined,
                  size: 48, color: AppColors.lightTextLight),
              const SizedBox(height: 12),
              Text('No data found',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.lightTextMuted)),
            ],
          ),
        ),
      );
}

class _ShimmerTable extends StatelessWidget {
  final int columns;
  const _ShimmerTable({required this.columns});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
      highlightColor:
          isDark ? const Color(0xFF4A5568) : const Color(0xFFF7FAFC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: List.generate(
                  columns,
                  (j) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable search field ─────────────────────────────────────────────────────
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const SearchField({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 260,
        height: 40,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search_rounded, size: 18),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            isDense: true,
          ),
        ),
      );
}

// ── Risk badge ────────────────────────────────────────────────────────────────
class RiskBadge extends StatelessWidget {
  final String level;
  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (level.toUpperCase()) {
      'CRITICAL' => (const Color(0xFFF3E8FF), AppColors.riskCritical),
      'HIGH' => (AppColors.errorSurface, AppColors.riskHigh),
      'MEDIUM' => (AppColors.warningSurface, AppColors.riskMedium),
      _ => (AppColors.successSurface, AppColors.riskLow),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(level,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final bool active;
  final String? activeLabel;
  final String? inactiveLabel;
  const StatusBadge(
      {super.key,
      required this.active,
      this.activeLabel,
      this.inactiveLabel});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.successSurface
              : AppColors.errorSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          active
              ? (activeLabel ?? 'Active')
              : (inactiveLabel ?? 'Inactive'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.success : AppColors.error,
          ),
        ),
      );
}
