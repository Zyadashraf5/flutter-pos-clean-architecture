import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../../domain/entities/order_entity.dart' show OrderEntity, OrderType;
import '../../layout/main_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_card.dart';
import 'orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: Obx(() {
          if (controller.selectMode.value) {
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => controller.deselectAll(),
            );
          }
          return const SizedBox.shrink();
        }),
        title: Obx(() => controller.selectMode.value
            ? Text('${controller.selectedCount} ${tr('selected', 'selected')}')
            : Text(tr('orders'))),
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
                  if (controller.canDeleteOrders)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: tr('delete_selected', 'Delete Selected'),
                      onPressed: () => _confirmBulkDelete(context, tr),
                    ),
                ],
              );
            }
            return Padding(
              padding: const EdgeInsets.only(left: 8, right: 16),
              child: FilledButton.icon(
                onPressed: () =>
                    Get.find<MainController>().goTo(AppRoutes.orderCreate),
                icon: const Icon(Icons.add, size: 20),
                label: Text(tr('new_order')),
              ),
            );
          }),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.sm
              : AppSpacing.md;
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
            final list = controller.orders;
            if (list.isEmpty) {
              return EmptyState(
                message: tr('no_orders_yet'),
                icon: Icons.receipt_long_outlined,
                actionLabel: tr('create_order'),
                onAction: () =>
                    Get.find<MainController>().goTo(AppRoutes.orderCreate),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(padding),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final o = list[i];
                return Obx(() {
                  final inSelectMode = controller.selectMode.value;
                  final isSelected = controller.isSelected(o.id);
                  return _OrderCard(
                    order: o,
                    tr: tr,
                    onView: () => _showOrderDetails(context, o, tr),
                    canDelete: controller.canDeleteOrders,
                    onDelete: () => _confirmDeleteOrder(context, o, tr),
                    inSelectMode: inSelectMode,
                    isSelected: isSelected,
                    onToggleSelect: () => controller.toggleSelect(o.id),
                    onLongPress: () {
                      if (!inSelectMode) controller.toggleSelect(o.id);
                    },
                  );
                });
              },
            );
          });
        },
      ),
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
          '${tr('confirm_bulk_delete', 'Delete')} ${controller.selectedCount} ${tr('orders', 'orders')}?',
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

  void _showOrderDetails(
    BuildContext context,
    OrderEntity order,
    String Function(String, [String?]) tr,
  ) {
    final parts = order.id.split('_');
    final orderLabel =
        order.orderNumber ?? (parts.isEmpty ? order.id : parts.last);
    final typeLabel = order.orderType == OrderType.cash
        ? tr('cash')
        : tr('credit');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('#$orderLabel'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(ctx).size.width * 0.9,
            minWidth: 280,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderDetailRow(
                  label: tr('order_type', 'Type'),
                  value: typeLabel,
                ),
                _OrderDetailRow(
                  label: tr('subtotal', 'Subtotal'),
                  value: LocaleFormat.currency(order.subtotal, context),
                ),
                _OrderDetailRow(
                  label: tr('tax', 'Tax'),
                  value: LocaleFormat.currency(order.taxAmount, context),
                ),
                _OrderDetailRow(
                  label: tr('total'),
                  value: LocaleFormat.currency(order.total, context),
                ),
                if (order.paidAmount != null)
                  _OrderDetailRow(
                    label: tr('paid_amount', 'Paid'),
                    value: LocaleFormat.currency(order.paidAmount!, context),
                  ),
                if (order.remainingAmount != null && order.remainingAmount! > 0)
                  _OrderDetailRow(
                    label: tr('remaining', 'Remaining'),
                    value: LocaleFormat.currency(
                      order.remainingAmount!,
                      context,
                    ),
                  ),
                _OrderDetailRow(
                  label: tr('date', 'Date'),
                  value: _formatFullDate(order.createdAt),
                ),
                if (order.createdByName != null &&
                    order.createdByName!.isNotEmpty)
                  _OrderDetailRow(
                    label: tr('created_by'),
                    value: order.createdByName!,
                  ),
                const Divider(height: 24),
                Text(
                  tr('items'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${tr('qty', 'Qty')}: ${item.quantity} × ${LocaleFormat.currency(item.unitPrice, context)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              if (item.taxPercent > 0)
                                Text(
                                  '${tr('tax', 'Tax')}: ${item.taxPercent.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          LocaleFormat.currency(item.lineTotal, context),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (controller.canDeleteOrders)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _confirmDeleteOrder(context, order, tr);
              },
              child: Text(
                tr('delete'),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('close', 'Close')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOrder(
    BuildContext context,
    OrderEntity order,
    String Function(String, [String?]) tr,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(tr('delete_order', 'Delete Order')),
        content: Text(
          '${tr('delete_order_confirm', 'Are you sure you want to delete order')} #${order.orderNumber ?? order.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteOrder(order.id);
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

  String _formatFullDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _OrderDetailRow extends StatelessWidget {
  const _OrderDetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.tr,
    required this.onView,
    this.canDelete = false,
    this.onDelete,
    this.inSelectMode = false,
    this.isSelected = false,
    this.onToggleSelect,
    this.onLongPress,
  });

  final OrderEntity order;
  final String Function(String key, [String? fallback]) tr;
  final VoidCallback onView;
  final bool canDelete;
  final VoidCallback? onDelete;
  final bool inSelectMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final parts = order.id.split('_');
    final orderLabel =
        order.orderNumber ?? (parts.isEmpty ? order.id : parts.last);
    final typeLabel = order.orderType == OrderType.cash
        ? tr('cash')
        : tr('credit');
    return ItemCard(
      onTap: inSelectMode ? onToggleSelect : onView,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Row(
          children: [
            if (inSelectMode)
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelect?.call(),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#$orderLabel',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} ${tr('items')} • $typeLabel',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (order.createdByName != null &&
                      order.createdByName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${tr('created_by')}: ${order.createdByName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PriceHighlight(value: LocaleFormat.currency(order.total, context)),
            const SizedBox(width: 8),
            ItemBadge(label: _formatDate(order.createdAt), isAccent: false),
            if (!inSelectMode && canDelete) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: tr('delete'),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}
