import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../layout/main_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_card.dart';
import 'inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('inventory')),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => Get.find<MainController>().goTo(
                AppRoutes.inventoryDeviceForm,
              ),
              icon: const Icon(Icons.phone_android, size: 20),
              label: Text(tr('add_device', 'Add Device')),
            ),
          ),
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
              // ── Search & Filter bar ──────────────────────────
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile) ...[
                      TextField(
                        decoration: InputDecoration(
                          hintText: tr('search_devices', 'Search devices...'),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (v) => controller.searchQuery.value = v,
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        return DropdownButtonFormField<String?>(
                          initialValue: controller.filterCategoryId.value,
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
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            controller.filterCategoryId.value = v;
                          },
                        );
                      }),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: tr(
                                  'search_devices',
                                  'Search devices...',
                                ),
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
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                controller.filterCategoryId.value = v;
                              },
                            );
                          }),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        '${tr('total_devices', 'Total Devices')}: ${controller.filteredDevices.length}  •  ${tr('current_inventory_value')}: ${LocaleFormat.currency(controller.totalInventoryValue, context)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Device list ─────────────────────────────────
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
                  final list = controller.filteredDevices;
                  if (list.isEmpty) {
                    return EmptyState(
                      message: tr('no_inventory'),
                      icon: Icons.warehouse_outlined,
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(padding),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final d = list[i];
                      return _DeviceCard(device: d, tr: tr);
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
}

// ═════════════════════════════════════════════════════════════════
//  Device card widget
// ═════════════════════════════════════════════════════════════════

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, required this.tr});
  final InventoryDeviceEntity device;
  final String Function(String key, [String? fallback]) tr;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<InventoryController>();
    final conditionLabel = device.condition == DeviceCondition.used
        ? tr('condition_used', 'Used')
        : tr('condition_new', 'New');
    final conditionColor = device.condition == DeviceCondition.used
        ? AppColors.warning
        : Colors.green;

    return ItemCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  device.deviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: conditionColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  conditionLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: conditionColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _InfoChip(icon: Icons.qr_code, label: device.barcode),
              _InfoChip(icon: Icons.color_lens_outlined, label: device.color),
              _InfoChip(icon: Icons.storage, label: device.storage),
              if (device.batteryHealth != null &&
                  device.batteryHealth!.isNotEmpty)
                _InfoChip(
                  icon: Icons.battery_std,
                  label: device.batteryHealth!,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${tr('serial_number_1', 'S/N 1')}: ${device.serialNumber1}  •  ${tr('serial_number_2', 'S/N 2')}: ${device.serialNumber2}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${tr('receiving_price', 'Price')}: ${LocaleFormat.currency(device.receivingPrice, context)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${tr('supplier_name', 'Supplier')}: ${device.supplierName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (ctrl.categoryName(device.categoryId).isNotEmpty) ...[
                const SizedBox(width: 16),
                Text(
                  ctrl.categoryName(device.categoryId),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
