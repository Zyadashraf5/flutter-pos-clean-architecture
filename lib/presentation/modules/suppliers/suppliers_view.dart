import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../domain/entities/supplier_entity.dart';
import '../../layout/main_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_card.dart';
import 'suppliers_controller.dart';

class SuppliersView extends GetView<SuppliersController> {
  const SuppliersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    final padding =
        MediaQuery.sizeOf(context).width < AppSpacing.breakpointCompact
        ? AppSpacing.sm
        : AppSpacing.md;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: Obx(() => controller.selectMode.value
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => controller.deselectAll(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    Get.find<MainController>().goTo(AppRoutes.financial),
              )),
        title: Obx(() => controller.selectMode.value
            ? Text('${controller.selectedCount} ${tr('selected', 'selected')}')
            : Text(tr('suppliers'))),
        actions: [
          Obx(() {
            if (controller.selectMode.value) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => controller.selectAll(),
                    child: Text(tr('select_all', 'Select All')),
                  ),
                  if (controller.canDeleteSupplier)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: tr('delete_selected', 'Delete Selected'),
                      onPressed: () => _confirmBulkDelete(context, tr),
                    ),
                ],
              );
            }
            return IconButton(
              icon: const Icon(Icons.add),
              tooltip: tr('add_supplier', 'Add Supplier'),
              onPressed: () {
                controller.editSupplierId.value = null;
                Get.find<MainController>().goTo(AppRoutes.supplierForm);
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.suppliers.isEmpty) {
          return EmptyState(
            message: tr(
              'no_suppliers',
              'No suppliers yet. Add a supplier when creating a purchase.',
            ),
            icon: Icons.business_center,
            actionLabel: tr('add_supplier', 'Add Supplier'),
            onAction: () {
              controller.editSupplierId.value = null;
              Get.find<MainController>().goTo(AppRoutes.supplierForm);
            },
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(padding),
          itemCount: controller.suppliers.length,
          itemBuilder: (_, i) {
            final s = controller.suppliers[i];
            return Obx(() {
              final inSelectMode = controller.selectMode.value;
              final isSelected = controller.isSelected(s.id);
              return ItemCard(
                child: Row(
                  children: [
                    if (inSelectMode)
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => controller.toggleSelect(s.id),
                      ),
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          if (!inSelectMode) {
                            controller.toggleSelect(s.id);
                          }
                        },
                        onTap: inSelectMode
                            ? () => controller.toggleSelect(s.id)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            if (s.phone != null)
                              Text(
                                s.phone!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              '${tr('debt', 'Debt')}: ${LocaleFormat.currency(s.totalDebt, context)} • ${tr('paid', 'Paid')}: ${LocaleFormat.currency(s.totalPaid, context)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!inSelectMode) ...[
                      IconButton(
                        onPressed: () {
                          controller.editSupplierId.value = s.id;
                          Get.find<MainController>()
                              .goTo(AppRoutes.supplierForm);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: tr('edit', 'Edit'),
                      ),
                      IconButton(
                        onPressed: () => _showPurchaseHistory(
                          context, controller, s.id, s.name, tr,
                        ),
                        icon: const Icon(Icons.history, size: 20),
                        tooltip: tr('purchase_history', 'Purchase History'),
                      ),
                      if (s.totalDebt > 0)
                        TextButton.icon(
                          onPressed: () => _showPaymentDialog(
                            context, controller, s.id, s.name, tr,
                          ),
                          icon: const Icon(Icons.payment, size: 18),
                          label: Text(tr('pay', 'Pay')),
                        ),
                      if (controller.canDeleteSupplier)
                        IconButton(
                          onPressed: () => _confirmDeleteSupplier(
                            context, controller, s, tr,
                          ),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: tr('delete'),
                        ),
                    ],
                  ],
                ),
              );
            });
          },
        );
      }),
    );
  }

  void _confirmBulkDelete(
    BuildContext context,
    String Function(String, [String?]) tr,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(tr('delete_selected', 'Delete Selected')),
        content: Text(
          '${tr('confirm_bulk_delete', 'Delete')} ${controller.selectedCount} ${tr('suppliers', 'suppliers')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSelected();
            },
            child: Text(
              tr('delete'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

void _showPurchaseHistory(
  BuildContext context,
  SuppliersController controller,
  String supplierId,
  String supplierName,
  String Function(String key, [String? fallback]) tr,
) {
  final purchases = controller.purchasesForSupplier(supplierId);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        '${tr('purchase_history', 'Purchase History')} – $supplierName',
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width * 0.9
            : 560,
        height: 400,
        child: purchases.isEmpty
            ? Center(
                child: Text(
                  tr('no_purchases', 'No purchases from this supplier yet.'),
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
              )
            : ListView.separated(
                itemCount: purchases.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = purchases[i];
                  final typeLabel = p.purchaseType == PurchaseType.cash
                      ? tr('cash')
                      : tr('credit');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_formatDate(p.createdAt)} • $typeLabel',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              LocaleFormat.currency(p.totalAmount, context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (p.purchaseType == PurchaseType.credit) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${tr('paid', 'Paid')}: ${LocaleFormat.currency(p.paidAmount, context)} • ${tr('remaining', 'Remaining')}: ${LocaleFormat.currency(p.remainingAmount, context)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        ...p.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 2),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${item.productName} × ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                                Text(
                                  LocaleFormat.currency(
                                    item.lineTotal,
                                    context,
                                  ),
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
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(tr('close', 'Close')),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime d) {
  return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

void _confirmDeleteSupplier(
  BuildContext context,
  SuppliersController controller,
  SupplierEntity supplier,
  String Function(String key, [String? fallback]) tr,
) {
  Get.dialog(
    AlertDialog(
      title: Text(tr('delete_supplier', 'Delete Supplier')),
      content: Text(
        '${tr('delete_supplier_confirm', 'Are you sure you want to delete')} "${supplier.name}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(tr('cancel')),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteSupplier(supplier.id);
          },
          child: Text(
            tr('delete'),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}

void _showPaymentDialog(
  BuildContext context,
  SuppliersController controller,
  String supplierId,
  String supplierName,
  String Function(String key, [String? fallback]) tr,
) {
  final amountController = TextEditingController();
  showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${tr('pay', 'Pay')} – $supplierName'),
      content: TextField(
        controller: amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: tr('amount', 'Amount')),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(tr('cancel')),
        ),
        FilledButton(
          onPressed: () async {
            final amount = double.tryParse(amountController.text);
            if (amount == null || amount <= 0) return;
            final ok = await controller.recordPayment(supplierId, amount);
            if (ctx.mounted) Navigator.of(ctx).pop();
            if (ok) {
              Get.snackbar(
                tr('success', 'Success'),
                tr('payment_recorded', 'Payment recorded'),
              );
            }
          },
          child: Text(tr('record', 'Record')),
        ),
      ],
    ),
  );
}
