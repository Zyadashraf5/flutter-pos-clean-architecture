import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../../domain/entities/financial_entity.dart';
import 'financial_controller.dart';

class FinancialView extends GetView<FinancialController> {
  const FinancialView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(tr('financial_overview')), elevation: 0),
      body: Obx(() {
        if (controller.loading.value && controller.summary.value == null) {
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= AppSpacing.breakpointTablet;
            final isMobile = constraints.maxWidth < AppSpacing.breakpointMobile;
            final padding = constraints.maxWidth < AppSpacing.breakpointCompact
                ? AppSpacing.sm
                : AppSpacing.md;
            return RefreshIndicator(
              onRefresh: () async {
                await controller.loadSummaryOnce();
                await controller.loadOrdersAndAnalytics();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('summary'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (s != null) ...[
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _SummaryGrid(
                                controller: controller,
                                s: s,
                                tr: tr,
                                singleColumn: false,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _ChartsSection(
                                controller: controller,
                                tr: tr,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SummaryGrid(
                              controller: controller,
                              s: s,
                              tr: tr,
                              singleColumn: isMobile,
                            ),
                            const SizedBox(height: 24),
                            _ChartsSection(controller: controller, tr: tr),
                          ],
                        ),
                      const SizedBox(height: 24),
                      _BreakdownSection(controller: controller, tr: tr),
                    ] else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(tr('no_data_yet')),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Text(
                      tr('default_tax_new_products'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: '${controller.defaultTaxPercent.value}',
                            ),
                            onSubmitted: (v) {
                              final n = double.tryParse(v);
                              if (n != null && n >= 0) {
                                controller.saveDefaultTax(n);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('%'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.controller,
    required this.s,
    required this.tr,
    this.singleColumn = false,
  });

  final FinancialController controller;
  final FinancialSummaryEntity s;
  final String Function(String key, [String? fallback]) tr;
  final bool singleColumn;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _SummaryCard(
        title: tr('total_sales'),
        value: LocaleFormat.currency(s.grossRevenue, context),
        icon: Icons.trending_up,
        color: AppColors.primary,
      ),
      _SummaryCard(
        title: 'Net Profit',
        value: LocaleFormat.currency(s.netProfit, context),
        icon: Icons.savings,
        color: AppColors.success,
      ),
      _SummaryCard(
        title: tr('total_credit'),
        value: LocaleFormat.currency(s.totalCredit, context),
        icon: Icons.credit_card,
        color: AppColors.warning,
      ),
      _SummaryCard(
        title: 'Supplier Debt',
        value: LocaleFormat.currency(s.supplierDebt, context),
        icon: Icons.business_center,
        color: AppColors.error,
      ),
      _SummaryCard(
        title: "Today's Sales",
        value: LocaleFormat.currency(controller.todaysSales.value, context),
        icon: Icons.today,
        color: AppColors.accent,
      ),
      _SummaryCard(
        title: "This Month",
        value: LocaleFormat.currency(controller.monthSales.value, context),
        icon: Icons.calendar_month,
        color: AppColors.primaryDark,
      ),
    ];

    if (singleColumn) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    // 2-column grid
    final rows = <Widget>[];
    for (int i = 0; i < cards.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: cards[i]),
            const SizedBox(width: 12),
            if (i + 1 < cards.length)
              Expanded(child: cards[i + 1])
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < cards.length) rows.add(const SizedBox(height: 12));
    }

    return Column(children: rows);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection({required this.controller, required this.tr});

  final FinancialController controller;
  final String Function(String key, [String? fallback]) tr;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 180,
              child: Obx(() {
                final data = controller.monthlySales;
                if (data.isEmpty) {
                  return Center(child: Text(tr('no_data_yet')));
                }
                final maxY = data.reduce((a, b) => a > b ? a : b);
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, meta) => Text(
                            maxY > 0 ? '${(v / maxY * 100).toInt()}%' : '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (v, meta) {
                            final i = v.toInt();
                            if (i >= 0 && i < 12) {
                              final m = DateTime.now().month - 11 + i;
                              final month = m <= 0 ? m + 12 : m;
                              return Text(
                                '$month',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
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
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 160,
              child: Obx(() {
                final data = controller.dailySales;
                if (data.isEmpty) {
                  return Center(child: Text(tr('no_data_yet')));
                }
                final last15 = data.length > 15
                    ? data.sublist(data.length - 15)
                    : data;
                final maxY = last15
                    .map((e) => e.total)
                    .reduce((a, b) => a > b ? a : b);
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY > 0 ? maxY * 1.1 : 1,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, meta) => Text(
                            maxY > 0 ? '${(v / maxY * 100).toInt()}%' : '',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (v, meta) {
                            final i = v.toInt();
                            if (i >= 0 && i < last15.length) {
                              return Text(
                                '${last15[i].day}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
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
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    barGroups: last15.asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.total,
                            color: AppColors.primaryLight,
                            width: 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                        showingTooltipIndicators: [],
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({required this.controller, required this.tr});

  final FinancialController controller;
  final String Function(String key, [String? fallback]) tr;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary.value;
    if (s == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 5 Selling Products',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final top = controller.topSellingProducts;
                  if (top.isEmpty) {
                    return Text(
                      tr('no_data_yet'),
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    );
                  }
                  return Column(
                    children: top
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    e.productName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('${e.quantity} ${tr('items')}'),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
                const SizedBox(height: 16),
                Obx(() {
                  final cat = controller.mostProfitableCategoryName.value;
                  return Text(
                    'Most profitable category: ${cat ?? tr('no_data_yet')}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Obx(() {
                  final cash = controller.cashTotal.value;
                  final credit = controller.creditTotal.value;
                  final total = controller.creditVsCashTotal;
                  if (total <= 0) {
                    return Text(
                      'Credit vs Cash: ${tr('no_data_yet')}',
                      style: const TextStyle(fontSize: 13),
                    );
                  }
                  return Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payments,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cash ${LocaleFormat.currency(cash, context)} (${(cash / total * 100).toStringAsFixed(0)}%)',
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Credit ${LocaleFormat.currency(credit, context)} (${(credit / total * 100).toStringAsFixed(0)}%)',
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                Text(
                  '${tr('taxes_collected')}: ${LocaleFormat.currency(s.taxesCollected, context)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
