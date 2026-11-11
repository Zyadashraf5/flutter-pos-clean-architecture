import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../layout/main_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_card.dart';
import '../../widgets/qr_product_dialog.dart';
import 'products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

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
            : Text(tr('products'))),
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
              onPressed: () {
                controller.editProductId.value = null;
                Get.find<MainController>().goTo(AppRoutes.productForm);
              },
            );
          }),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.sm
              : AppSpacing.md;
          final isMobile = constraints.maxWidth < AppSpacing.breakpointMobile;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: isMobile
                    ? Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: tr('search_products'),
                              prefixIcon: const Icon(Icons.search),
                            ),
                            onChanged: (v) => controller.searchQuery.value = v,
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            return DropdownButtonFormField<String?>(
                              value: controller.filterCategoryId.value,
                              decoration: InputDecoration(
                                labelText: tr('all_categories'),
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(tr('all_categories')),
                                ),
                                ...controller.categories.map(
                                  (CategoryEntity c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                controller.filterCategoryId.value = v;
                                controller.loadProducts();
                              },
                            );
                          }),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: tr('search_products'),
                                prefixIcon: const Icon(Icons.search),
                              ),
                              onChanged: (v) =>
                                  controller.searchQuery.value = v,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Obx(() {
                            return DropdownButton<String?>(
                              value: controller.filterCategoryId.value,
                              hint: Text(tr('all_categories')),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(tr('all_categories')),
                                ),
                                ...controller.categories.map(
                                  (CategoryEntity c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                controller.filterCategoryId.value = v;
                                controller.loadProducts();
                              },
                            );
                          }),
                        ],
                      ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.loading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    );
                  }
                  final list = controller.filteredProducts;
                  if (list.isEmpty) {
                    return EmptyState(
                      message: tr('no_products'),
                      icon: Icons.inventory_2_outlined,
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final p = list[i];
                      return Obx(() {
                        final inSelectMode = controller.selectMode.value;
                        final isSelected = controller.isSelected(p.id);
                        return _ProductCard(
                          product: p,
                          categoryName:
                              _categoryName(controller, p.categoryId),
                          tr: tr,
                          onView: () => _showProductDetails(
                            context,
                            p,
                            _categoryName(controller, p.categoryId),
                            tr,
                          ),
                          onEdit: () {
                            controller.editProductId.value = p.id;
                            Get.find<MainController>().goTo(
                              AppRoutes.productForm,
                            );
                          },
                          onDelete: () => _confirmDelete(controller, p, tr),
                          onQr: () => showQrProductDialog(context, p),
                          inSelectMode: inSelectMode,
                          isSelected: isSelected,
                          onToggleSelect: () =>
                              controller.toggleSelect(p.id),
                          onLongPress: () {
                            if (!inSelectMode) {
                              controller.toggleSelect(p.id);
                            }
                          },
                        );
                      });
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  String _categoryName(ProductsController ctrl, String id) {
    try {
      return ctrl.categories.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return '-';
    }
  }

  void _confirmDelete(
    ProductsController ctrl,
    ProductEntity p,
    String Function(String) tr,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(tr('delete')),
        content: Text('${tr('delete')} "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr('cancel'))),
          Obx(() => TextButton(
                onPressed: ctrl.deleting.value
                    ? null
                    : () async {
                        Get.back();
                        await ctrl.deleteProduct(p.id);
                      },
                child: ctrl.deleting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        tr('delete'),
                        style: const TextStyle(color: AppColors.error),
                      ),
              )),
        ],
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
          '${tr('confirm_bulk_delete', 'Delete')} ${controller.selectedCount} ${tr('products', 'products')}?',
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

  void _showProductDetails(
    BuildContext context,
    ProductEntity p,
    String categoryName,
    String Function(String, [String?]) tr,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p.name),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(ctx).size.width * 0.9,
            minWidth: 280,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: tr('category'), value: categoryName),
              _DetailRow(
                label: tr('barcode'),
                value: p.barcode.isEmpty ? '-' : p.barcode,
              ),
              _DetailRow(
                label: tr('purchase_price'),
                value: LocaleFormat.currency(p.purchasePrice, context),
              ),
              _DetailRow(
                label: tr('selling_price'),
                value: LocaleFormat.currency(p.sellingPrice, context),
              ),
              _DetailRow(
                label: tr('quantity'),
                value: LocaleFormat.number(p.quantity, context),
              ),
              _DetailRow(
                label: tr('tax_percent', 'Tax %'),
                value: '${p.taxPercent.toStringAsFixed(1)}%',
              ),
              if (p.createdAt != null)
                _DetailRow(
                  label: tr('created_at', 'Created'),
                  value: _formatDate(p.createdAt!),
                ),
              if (p.updatedAt != null)
                _DetailRow(
                  label: tr('updated_at', 'Updated'),
                  value: _formatDate(p.updatedAt!),
                ),
              _DetailRow(
                label: tr('status', 'Status'),
                value: p.isActive
                    ? tr('active', 'Active')
                    : tr('inactive', 'Inactive'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              showQrProductDialog(context, p);
            },
            child: Text(tr('show_qr', 'QR Code')),
          ),
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
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.categoryName,
    required this.tr,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onQr,
    this.inSelectMode = false,
    this.isSelected = false,
    this.onToggleSelect,
    this.onLongPress,
  });

  final ProductEntity product;
  final String categoryName;
  final String Function(String key, [String? fallback]) tr;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQr;
  final bool inSelectMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < AppSpacing.breakpointMobile;

    if (isMobile) {
      return GestureDetector(
        onLongPress: onLongPress,
        child: ItemCard(
          onTap: inSelectMode ? onToggleSelect : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (inSelectMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggleSelect?.call(),
                    ),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$categoryName • ${tr('stock')}: ${LocaleFormat.number(product.quantity, context)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ItemBadge(
                    label: '${product.taxPercent.toStringAsFixed(0)}%',
                    isAccent: false,
                  ),
                  const SizedBox(width: 8),
                  PriceHighlight(
                    value: LocaleFormat.currency(product.sellingPrice, context),
                  ),
                  const Spacer(),
                  if (!inSelectMode) ...[
                    IconButton(
                      icon: const Icon(Icons.qr_code, size: 20),
                      tooltip: tr('show_qr', 'QR Code'),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: onQr,
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 20),
                      tooltip: tr('view', 'View'),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: onView,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: onDelete,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: ItemCard(
        onTap: inSelectMode ? onToggleSelect : null,
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
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryName • ${tr('stock')}: ${LocaleFormat.number(product.quantity, context)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ItemBadge(
              label: '${product.taxPercent.toStringAsFixed(0)}%',
              isAccent: false,
            ),
            const SizedBox(width: 8),
            PriceHighlight(
              value: LocaleFormat.currency(product.sellingPrice, context),
            ),
            if (!inSelectMode) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.qr_code),
                tooltip: tr('show_qr', 'QR Code'),
                onPressed: onQr,
              ),
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: tr('view', 'View'),
                onPressed: onView,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
