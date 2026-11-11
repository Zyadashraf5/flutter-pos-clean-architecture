import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import 'admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  void _confirmClear(
    BuildContext context,
    String Function(String key, [String? fallback]) tr,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('clear_confirm_title')),
        content: Text(tr('clear_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.clearDatabase();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(tr('clear')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(tr('admin')), elevation: 0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.md
              : AppSpacing.lg;
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('firestore_database'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Obx(() {
                      return ElevatedButton.icon(
                        onPressed: controller.loading.value
                            ? null
                            : () => controller.seedDatabase(),
                        icon: controller.loading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.grass),
                        label: Text(tr('seed_database')),
                      );
                    }),
                    Obx(() {
                      return OutlinedButton.icon(
                        onPressed: controller.loading.value
                            ? null
                            : () => _confirmClear(context, tr),
                        icon: const Icon(Icons.delete_sweep),
                        label: Text(tr('clear_database')),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  tr('stats_firestore'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.loading.value &&
                      controller.stats.value == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              tr('loading'),
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final s = controller.stats.value;
                  if (s == null) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(tr('no_data_seed')),
                    );
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatRow(tr('categories'), '${s.categoriesCount}'),
                          _StatRow(tr('products'), '${s.productsCount}'),
                          _StatRow(tr('orders'), '${s.ordersCount}'),
                          if (s.financialSummary != null) ...[
                            const Divider(),
                            _StatRow(
                              tr('total_sales'),
                              LocaleFormat.currency(
                                s.financialSummary!.totalSales,
                                context,
                              ),
                            ),
                            _StatRow(
                              tr('cash_you_have'),
                              LocaleFormat.currency(
                                s.financialSummary!.totalCash,
                                context,
                              ),
                            ),
                            _StatRow(
                              tr('total_credit'),
                              LocaleFormat.currency(
                                s.financialSummary!.totalCredit,
                                context,
                              ),
                            ),
                            _StatRow(
                              tr('taxes_collected'),
                              LocaleFormat.currency(
                                s.financialSummary!.taxesCollected,
                                context,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
