import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../widgets/empty_state.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('dashboard')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadSummary(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.sm
              : AppSpacing.lg;
          return Obx(() {
            if (controller.loading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      tr('loading'),
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }
            final s = controller.summary.value;
            if (s == null) {
              return EmptyState(
                message: tr('no_data_yet'),
                icon: Icons.dashboard_outlined,
              );
            }
            return _DashboardContent(
              controller: controller,
              s: s,
              padding: padding,
              tr: tr,
            );
          });
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.controller,
    required this.s,
    required this.padding,
    required this.tr,
  });

  final DashboardController controller;
  final dynamic s;
  final double padding;
  final String Function(String key, [String? fallback]) tr;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < AppSpacing.breakpointMobile;
        // On mobile: 1 card per row, on larger: 2 per row
        final crossAxisCount = isMobile ? 1 : 2;
        final stackCharts = width < AppSpacing.breakpointTablet;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary Cards ──
              Text(
                tr('overview'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Stat cards in a responsive wrap grid
              _ResponsiveCardGrid(
                crossAxisCount: crossAxisCount,
                children: [
                  _StatCard(
                    title: tr('total_sales'),
                    value: LocaleFormat.currency(s.totalSales, context),
                    icon: Icons.trending_up,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    title: tr('total_orders'),
                    value: LocaleFormat.number(s.totalOrders, context),
                    icon: Icons.receipt_long,
                    color: AppColors.accent,
                  ),
                  _StatCard(
                    title: tr('cash_you_have'),
                    value: LocaleFormat.currency(s.totalCash, context),
                    icon: Icons.payments,
                    color: AppColors.success,
                  ),
                  _StatCard(
                    title: tr('credit_to_collect'),
                    value: LocaleFormat.currency(s.totalCredit, context),
                    icon: Icons.people_outline,
                    color: AppColors.accent,
                  ),
                  _StatCard(
                    title: tr('money_you_owe'),
                    value: LocaleFormat.currency(s.supplierDebt, context),
                    icon: Icons.credit_card,
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    title: tr('inventory_value'),
                    value: LocaleFormat.currency(s.inventoryValue, context),
                    icon: Icons.inventory,
                    color: AppColors.primaryDark,
                  ),
                  _StatCard(
                    title: tr('taxes_collected'),
                    value: LocaleFormat.currency(s.taxesCollected, context),
                    icon: Icons.account_balance,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Chart 1: Daily Sales ──
              _ChartSection(
                title: tr('daily_sales', 'Daily Sales (Last 7 Days)'),
                child: _DailySalesChart(data: controller.dailySales, tr: tr),
              ),
              const SizedBox(height: 24),

              // ── Charts 2 & 3: side-by-side on desktop, stacked on mobile/tablet ──
              if (stackCharts) ...[
                _ChartSection(
                  title: tr('cash_vs_credit', 'Cash vs Credit'),
                  child: _CashCreditPieChart(
                    data: controller.paymentTotals,
                    tr: tr,
                  ),
                ),
                const SizedBox(height: 24),
                _ChartSection(
                  title: tr('top_products', 'Top 5 Products'),
                  child: _TopProductsChart(
                    data: controller.topProducts,
                    tr: tr,
                  ),
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ChartSection(
                        title: tr('cash_vs_credit', 'Cash vs Credit'),
                        child: _CashCreditPieChart(
                          data: controller.paymentTotals,
                          tr: tr,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ChartSection(
                        title: tr('top_products', 'Top 5 Products'),
                        child: _TopProductsChart(
                          data: controller.topProducts,
                          tr: tr,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Responsive Card Grid ────────────────────────────────────────

class _ResponsiveCardGrid extends StatelessWidget {
  const _ResponsiveCardGrid({
    required this.crossAxisCount,
    required this.children,
  });
  final int crossAxisCount;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    for (int i = 0; i < children.length; i += crossAxisCount) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < crossAxisCount; j++) {
        if (i + j < children.length) {
          rowChildren.add(Expanded(child: children[i + j]));
        } else {
          rowChildren.add(const Expanded(child: SizedBox()));
        }
        if (j < crossAxisCount - 1) rowChildren.add(const SizedBox(width: 16));
      }
      rows.add(Row(children: rowChildren));
      if (i + crossAxisCount < children.length) {
        rows.add(const SizedBox(height: 12));
      }
    }
    return Column(children: rows);
  }
}

// ── Chart Section Wrapper ───────────────────────────────────────

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Chart 1: Daily Sales Bar Chart ──────────────────────────────

class _DailySalesChart extends StatelessWidget {
  const _DailySalesChart({required this.data, required this.tr});
  final Map<DateTime, double> data;
  final String Function(String, [String?]) tr;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('No data')));
    }
    final entries = data.entries.toList();
    final maxY = entries.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    final topY = maxY == 0 ? 100.0 : (maxY * 1.2);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: topY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  LocaleFormat.currency(rod.toY, context),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final day = entries[i].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${day.day}/${day.month}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    _shortNumber(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: topY / 4,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: AppColors.surfaceVariant, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(entries.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value,
                  color: AppColors.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: topY,
                    color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _shortNumber(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Chart 2: Cash vs Credit Pie Chart ───────────────────────────

class _CashCreditPieChart extends StatelessWidget {
  const _CashCreditPieChart({required this.data, required this.tr});
  final ({double cash, double credit, double transfer}) data;
  final String Function(String, [String?]) tr;

  @override
  Widget build(BuildContext context) {
    final total = data.cash + data.credit + data.transfer;
    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No orders')),
      );
    }
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 36,
                sections: [
                  PieChartSectionData(
                    value: data.cash,
                    color: AppColors.success,
                    title: '${(data.cash / total * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: data.credit,
                    color: AppColors.warning,
                    title: '${(data.credit / total * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                  if (data.transfer > 0)
                    PieChartSectionData(
                      value: data.transfer,
                      color: AppColors.primary,
                      title:
                          '${(data.transfer / total * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 50,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                color: AppColors.success,
                label: tr('cash'),
                value: LocaleFormat.currency(data.cash, context),
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: AppColors.warning,
                label: tr('credit'),
                value: LocaleFormat.currency(data.credit, context),
              ),
              if (data.transfer > 0) ...[
                const SizedBox(height: 8),
                _LegendItem(
                  color: AppColors.primary,
                  label: tr('transfer'),
                  value: LocaleFormat.currency(data.transfer, context),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Chart 3: Top Products Bar Chart ─────────────────────────────

class _TopProductsChart extends StatelessWidget {
  const _TopProductsChart({required this.data, required this.tr});
  final List<({String name, double revenue})> data;
  final String Function(String, [String?]) tr;

  static const _barColors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    AppColors.warning,
    AppColors.primaryDark,
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('No data')));
    }
    final maxY = data.fold<double>(0, (m, e) => e.revenue > m ? e.revenue : m);
    final topY = maxY == 0 ? 100.0 : maxY * 1.2;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: topY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final name = groupIndex < data.length
                    ? data[groupIndex].name
                    : '';
                return BarTooltipItem(
                  '$name\n${LocaleFormat.currency(rod.toY, context)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  final name = data[i].name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 60,
                      child: Text(
                        name.length > 8 ? '${name.substring(0, 8)}…' : name,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    _shortNumber(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: topY / 4,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: AppColors.surfaceVariant, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].revenue,
                  color: _barColors[i % _barColors.length],
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _shortNumber(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Stat Card ───────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
