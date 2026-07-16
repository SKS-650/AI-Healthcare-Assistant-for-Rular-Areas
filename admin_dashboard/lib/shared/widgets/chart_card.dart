import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

/// Generic line chart card
class LineChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ChartSeries> series;
  final int animDelay;

  const LineChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.series,
    this.animDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitle!,
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(_buildChart()),
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(
              spacing: 16,
              children: series
                  .map((s) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: s.color,
                                borderRadius: BorderRadius.circular(3),
                              )),
                          const SizedBox(width: 6),
                          Text(s.label,
                              style:
                                  Theme.of(context).textTheme.labelSmall),
                        ],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animDelay), duration: 500.ms);
  }

  LineChartData _buildChart() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.lightBorder.withOpacity(0.5), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.lightTextMuted),
                  )),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: series.isNotEmpty && series[0].spots.length > 7
                  ? (series[0].spots.length / 7).ceilToDouble()
                  : 1,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (series.isEmpty ||
                    idx < 0 ||
                    idx >= series[0].labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    series[0].labels[idx],
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.lightTextMuted),
                  ),
                );
              }),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: series
          .map((s) => LineChartBarData(
                spots: s.spots,
                isCurved: true,
                color: s.color,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: s.color.withOpacity(0.08),
                ),
              ))
          .toList(),
    );
  }
}

/// Bar chart card
class BarChartCard extends StatelessWidget {
  final String title;
  final List<BarGroup> groups;
  final int animDelay;

  const BarChartCard({
    super.key,
    required this.title,
    required this.groups,
    this.animDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: BarChart(BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.lightBorder.withOpacity(0.5),
                      strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                              v.toInt().toString(),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.lightTextMuted),
                            )),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= groups.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(groups[idx].label,
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.lightTextMuted)),
                          );
                        }),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: groups
                    .asMap()
                    .entries
                    .map((e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.value.toDouble(),
                              color: e.value.color ??
                                  AppColors.chartPalette[
                                      e.key % AppColors.chartPalette.length],
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        ))
                    .toList(),
              )),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animDelay), duration: 500.ms);
  }
}

/// Donut / Pie chart card
class DonutChartCard extends StatelessWidget {
  final String title;
  final List<PieSlice> slices;
  final int animDelay;

  const DonutChartCard({
    super.key,
    required this.title,
    required this.slices,
    this.animDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: PieChart(PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: slices
                        .map((s) => PieChartSectionData(
                              value: s.value.toDouble(),
                              color: s.color,
                              radius: 40,
                              showTitle: false,
                            ))
                        .toList(),
                  )),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: slices
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: s.color,
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(s.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium),
                                  ),
                                  Text(
                                    s.value.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animDelay), duration: 500.ms);
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class ChartSeries {
  final String label;
  final Color color;
  final List<FlSpot> spots;
  final List<String> labels;

  ChartSeries({
    required this.label,
    required this.color,
    required this.spots,
    this.labels = const [],
  });

  static ChartSeries fromMapList(
    List<Map<String, dynamic>> data,
    String yKey,
    String labelKey,
    String label,
    Color color,
  ) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              ((e.value[yKey] as num?) ?? 0).toDouble(),
            ))
        .toList();
    final labels = data
        .map((d) {
          final raw = d[labelKey] as String? ?? '';
          // Shorten date: "2024-01-15" → "1/15"
          if (raw.contains('-') && raw.length == 10) {
            try {
              final dt = DateFormat('yyyy-MM-dd').parse(raw);
              return DateFormat('M/d').format(dt);
            } catch (_) {}
          }
          return raw;
        })
        .toList();
    return ChartSeries(
        label: label, color: color, spots: spots, labels: labels);
  }
}

class BarGroup {
  final String label;
  final int value;
  final Color? color;
  const BarGroup({required this.label, required this.value, this.color});
}

class PieSlice {
  final String label;
  final int value;
  final Color color;
  const PieSlice(
      {required this.label, required this.value, required this.color});
}
