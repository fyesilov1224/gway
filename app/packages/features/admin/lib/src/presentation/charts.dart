import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// One line or bar set of a chart; its color comes from its place (docs/DESIGN.md §1, Grafikler).
class ChartSeries {
  const ChartSeries(this.label, this.points, {int? total}) : _total = total;

  final String label;
  final List<int> points;
  final int? _total;

  /// The range's total; a measure that does not add up across buckets (distinct people) passes its own.
  int get total => _total ?? points.fold(0, (a, b) => a + b);
}

/// How values read on axes, in tooltips and in tables.
typedef ChartFormat = String Function(int value);

String _countFormat(int v) => formatCount(v);

/// A bucket's date: the day, or the week's first and last day.
String bucketLabel(DateTime start, {required bool weekly}) =>
    weekly ? '${formatDayMonthTr(start)} – ${formatDayMonthTr(start.add(const Duration(days: 6)))}' : formatDateTr(start);

/// A round top for the y axis and a step that gives four or five grid lines.
({double max, double step}) _niceScale(int max) {
  if (max <= 0) return (max: 4, step: 1);
  final rough = max / 4;
  final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  // Counts and minor units are whole numbers: a step under one would print the same label twice.
  final step = math.max(1.0, [1, 2, 2.5, 5, 10].map((m) => m * magnitude).firstWhere((s) => s >= rough));
  return (max: (max / step).ceil() * step, step: step);
}

/// Change over time for up to four series (docs/DESIGN.md §1, Grafikler): lines by default, grouped bars with
/// [bars]. A single series may lay its [previous] range under it as a grey dashed line.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.buckets,
    required this.series,
    required this.weekly,
    this.previous,
    this.bars = false,
    this.format = _countFormat,
    this.axisFormat = formatCompactTr,
    this.height = GxSpacing.xxl * 5,
  }) : assert(series.length <= 4, 'Fold a fifth series into another chart');

  final List<DateTime> buckets;
  final List<ChartSeries> series;
  final bool weekly;
  final List<int>? previous;
  final bool bars;
  final ChartFormat format;
  final String Function(num value) axisFormat;
  final double height;

  int get _max => [
        for (final s in series) ...s.points,
        ...?previous,
      ].fold(0, math.max);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final axisStyle = textTheme.labelSmall?.copyWith(color: GxColors.textSecondary);
    final scale = _niceScale(_max);
    // About six date labels whatever the range.
    final labelEvery = math.max(1, (buckets.length / 6).ceil());

    Widget bottom(double value, TitleMeta meta) {
      final i = value.round();
      // Counted from the newest bucket, so today always has its date.
      if (i < 0 || i >= buckets.length || (buckets.length - 1 - i) % labelEvery != 0 || value != i) return const SizedBox.shrink();
      return SideTitleWidget(
        meta: meta,
        fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
        child: Text(formatDayMonthTr(buckets[i]), style: axisStyle),
      );
    }

    Widget left(double value, TitleMeta meta) =>
        value > scale.max
            ? const SizedBox.shrink()
            : SideTitleWidget(
                meta: meta,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                child: Text(axisFormat(value), style: axisStyle),
              );

    final titles = FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: GxSpacing.lg, getTitlesWidget: bottom),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: true, interval: scale.step, reservedSize: GxSpacing.xxl, getTitlesWidget: left),
      ),
    );
    final grid = FlGridData(
      drawVerticalLine: false,
      horizontalInterval: scale.step,
      getDrawingHorizontalLine: (_) => const FlLine(color: GxColors.chartGrid, strokeWidth: 1),
    );
    const tooltipBorder = BorderSide(color: GxColors.border);
    final tooltipTitle = textTheme.labelMedium?.copyWith(color: GxColors.textSecondary);
    final tooltipValue = textTheme.labelLarge?.copyWith(color: GxColors.textPrimary);

    // The tooltip lists every series of the bucket under its date, in text colors (the legend carries identity).
    List<TextSpan> lines(int i) => [
          for (final (n, s) in series.indexed)
            TextSpan(text: '${n == 0 ? '' : '\n'}${s.label}: ${format(s.points[i])}', style: tooltipValue),
          if (previous != null) TextSpan(text: '\nÖnceki dönem: ${format(previous![i])}', style: tooltipTitle),
        ];

    final chart = bars
        ? BarChart(
            BarChartData(
              minY: 0,
              maxY: scale.max,
              titlesData: titles,
              gridData: grid,
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => GxColors.background,
                  tooltipBorder: tooltipBorder,
                  tooltipBorderRadius: GxRadius.mdAll,
                  maxContentWidth: GxSpacing.xxl * 5,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  // One tooltip per bucket, on its first bar.
                  getTooltipItem: (group, _, _, rodIndex) => rodIndex != 0
                      ? null
                      : BarTooltipItem('${bucketLabel(buckets[group.x], weekly: weekly)}\n', tooltipTitle!,
                          textAlign: TextAlign.start, children: lines(group.x)),
                ),
              ),
              barGroups: [
                for (var i = 0; i < buckets.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 2,
                    barRods: [
                      for (final (n, s) in series.indexed)
                        BarChartRodData(
                          toY: s.points[i].toDouble(),
                          color: GxColors.chartSeries[n],
                          width: 0,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(GxSpacing.xxs)),
                        ),
                    ],
                  ),
              ],
            ),
          )
        : LineChart(
            LineChartData(
              minX: 0,
              maxX: math.max(1, buckets.length - 1).toDouble(),
              minY: 0,
              maxY: scale.max,
              titlesData: titles,
              gridData: grid,
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                getTouchedSpotIndicator: (bar, indexes) => [
                  for (final _ in indexes)
                    TouchedSpotIndicatorData(
                      const FlLine(color: GxColors.border, strokeWidth: 1),
                      FlDotData(
                        getDotPainter: (_, _, line, _) => FlDotCirclePainter(
                          radius: GxSpacing.xxs,
                          color: line.color ?? GxColors.primary,
                          strokeWidth: 2,
                          strokeColor: GxColors.background,
                        ),
                      ),
                    ),
                ],
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => GxColors.background,
                  tooltipBorder: tooltipBorder,
                  tooltipBorderRadius: GxRadius.mdAll,
                  maxContentWidth: GxSpacing.xxl * 5,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  // One block on the first line; the others stay empty so the values are not repeated.
                  getTooltipItems: (spots) => [
                    for (final (n, spot) in spots.indexed)
                      n == 0
                          ? LineTooltipItem('${bucketLabel(buckets[spot.x.round()], weekly: weekly)}\n', tooltipTitle!,
                              textAlign: TextAlign.start, children: lines(spot.x.round()))
                          : null,
                  ],
                ),
              ),
              lineBarsData: [
                if (previous case final p?)
                  LineChartBarData(
                    spots: [for (final (i, v) in p.indexed) FlSpot(i.toDouble(), v.toDouble())],
                    color: GxColors.chartCompare,
                    barWidth: 1.5,
                    dashArray: const [4, 4],
                    dotData: const FlDotData(show: false),
                  ),
                // Counts are drawn straight (a curve invents values between days); the first series on top.
                for (final (n, s) in series.indexed.toList().reversed)
                  LineChartBarData(
                    spots: [for (final (i, v) in s.points.indexed) FlSpot(i.toDouble(), v.toDouble())],
                    color: GxColors.chartSeries[n],
                    barWidth: 2,
                    isStrokeJoinRound: true,
                    dotData: FlDotData(show: buckets.length <= 1),
                    belowBarData: series.length == 1
                        ? BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [GxColors.chartSeries[n].withValues(alpha: 0.16), GxColors.chartSeries[n].withValues(alpha: 0)],
                            ),
                          )
                        : BarAreaData(),
                  ),
              ],
            ),
          );

    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, size) {
        if (!bars) return chart;
        // Bars share the plot width: a gap of one bar between buckets, 2 px between a bucket's bars.
        final plot = size.maxWidth - GxSpacing.xxl;
        final width = (plot / buckets.length / (series.length + 1)).clamp(2.0, GxSpacing.md);
        final data = (chart as BarChart).data;
        return BarChart(data.copyWith(barGroups: [
          for (final g in data.barGroups) g.copyWith(barRods: [for (final r in g.barRods) r.copyWith(width: width)]),
        ]));
      }),
    );
  }
}

/// The current range as a small line over the previous one; no axes, no touch.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.points, required this.previous, this.color = GxColors.primary});

  final List<int> points;
  final List<int> previous;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final max = [...points, ...previous].fold(0, math.max);
    LineChartBarData line(List<int> values, Color color, {bool dashed = false}) => LineChartBarData(
          spots: [for (final (i, v) in values.indexed) FlSpot(i.toDouble(), v.toDouble())],
          color: color,
          barWidth: dashed ? 1 : 2,
          dashArray: dashed ? const [3, 3] : null,
          isStrokeJoinRound: true,
          dotData: const FlDotData(show: false),
        );
    return ExcludeSemantics(
      child: SizedBox(
        height: GxSpacing.xl,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: math.max(1, max).toDouble(),
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [line(previous, GxColors.chartCompare, dashed: true), line(points, color)],
          ),
        ),
      ),
    );
  }
}

/// Names each series by its color, with its total; always shown for two series or more.
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.series, this.format = _countFormat, this.showPrevious = false});

  final List<ChartSeries> series;
  final ChartFormat format;
  final bool showPrevious;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget item(Color color, String label, String? value, {bool dashed = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: GxSpacing.sm,
              height: dashed ? 2 : GxSpacing.sm,
              decoration: BoxDecoration(color: color, borderRadius: dashed ? null : const BorderRadius.all(Radius.circular(GxSpacing.xxs / 2))),
            ),
            const SizedBox(width: GxSpacing.xs),
            Text(label, style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
            if (value != null) ...[
              const SizedBox(width: GxSpacing.xxs),
              Text(value, style: textTheme.labelLarge?.copyWith(color: GxColors.textPrimary)),
            ],
          ],
        );
    return Wrap(
      spacing: GxSpacing.md,
      runSpacing: GxSpacing.xs,
      children: [
        for (final (n, s) in series.indexed) item(GxColors.chartSeries[n], s.label, format(s.total)),
        if (showPrevious) item(GxColors.chartCompare, 'Önceki dönem', null, dashed: true),
      ],
    );
  }
}

/// The chart's numbers as a table: the accessible view of every chart.
class ChartTable extends StatelessWidget {
  const ChartTable({super.key, required this.buckets, required this.series, required this.weekly, this.format = _countFormat});

  final List<DateTime> buckets;
  final List<ChartSeries> series;
  final bool weekly;
  final ChartFormat format;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final head = textTheme.labelMedium?.copyWith(color: GxColors.textSecondary);
    final body = textTheme.bodyMedium;
    Widget cell(String text, TextStyle? style, {bool end = false}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs, vertical: GxSpacing.xxs),
          child: Text(text, style: style, textAlign: end ? TextAlign.end : TextAlign.start),
        );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: GxSpacing.xxl * 6),
      child: SingleChildScrollView(
        child: Table(
          columnWidths: const {0: FlexColumnWidth(2)},
          border: const TableBorder(horizontalInside: GxBorders.hairline),
          children: [
            TableRow(children: [
              cell(weekly ? 'Hafta' : 'Gün', head),
              for (final s in series) cell(s.label, head, end: true),
            ]),
            // Newest first, as the eye looks for today.
            for (var i = buckets.length - 1; i >= 0; i--)
              TableRow(children: [
                cell(bucketLabel(buckets[i], weekly: weekly), body),
                for (final s in series) cell(format(s.points[i]), body, end: true),
              ]),
            TableRow(children: [
              cell('Toplam', head),
              for (final s in series) cell(format(s.total), textTheme.labelLarge, end: true),
            ]),
          ],
        ),
      ),
    );
  }
}

/// A titled chart with its legend and a switch to the table view.
class ChartPanel extends StatefulWidget {
  const ChartPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buckets,
    required this.series,
    required this.weekly,
    this.previous,
    this.bars = false,
    this.format = _countFormat,
    this.axisFormat = formatCompactTr,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final List<DateTime> buckets;
  final List<ChartSeries> series;
  final bool weekly;
  final List<int>? previous;
  final bool bars;
  final ChartFormat format;
  final String Function(num value) axisFormat;

  /// Extra controls beside the table switch, e.g. a currency choice.
  final Widget? trailing;

  @override
  State<ChartPanel> createState() => _ChartPanelState();
}

class _ChartPanelState extends State<ChartPanel> {
  bool _table = false;

  @override
  Widget build(BuildContext context) {
    final empty = widget.series.every((s) => s.total == 0) && (widget.previous ?? const []).every((v) => v == 0);
    final summary = [for (final s in widget.series) '${s.label} ${widget.format(s.total)}'].join(', ');
    return GxPanel(
      title: widget.title,
      subtitle: widget.subtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?widget.trailing,
          IconButton(
            tooltip: _table ? 'Grafik olarak göster' : 'Tablo olarak göster',
            icon: Icon(_table ? Icons.show_chart_rounded : Icons.table_rows_outlined),
            onPressed: () => setState(() => _table = !_table),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChartLegend(series: widget.series, format: widget.format, showPrevious: widget.previous != null),
          const SizedBox(height: GxSpacing.md),
          if (empty)
            SizedBox(
              height: GxSpacing.xxl * 3,
              child: Center(
                child: Text(
                  'Bu dönemde kayıt yok.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                ),
              ),
            )
          else if (_table)
            ChartTable(buckets: widget.buckets, series: widget.series, weekly: widget.weekly, format: widget.format)
          else
            Semantics(
              label: '${widget.title} grafiği: $summary. Ayrıntı için tablo görünümünü aç.',
              child: TrendChart(
                buckets: widget.buckets,
                series: widget.series,
                weekly: widget.weekly,
                previous: widget.previous,
                bars: widget.bars,
                format: widget.format,
                axisFormat: widget.axisFormat,
              ),
            ),
        ],
      ),
    );
  }
}
