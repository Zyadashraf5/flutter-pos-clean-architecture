import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../../domain/entities/order_entity.dart' show OrderType;
import '../../layout/main_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_card.dart';
import 'orders_controller.dart';

class OrderCreateView extends GetView<OrdersController> {
  const OrderCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('new_order')),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.find<MainController>().goTo(AppRoutes.orders),
        ),
      ),
      body: Column(
        children: [
          _BarcodeInputBar(controller: controller, tr: tr),
          Expanded(
            child: Obx(() {
              if (controller.cart.isEmpty) {
                return EmptyState(
                  message: '${tr('empty_cart')}\n${tr('scanner_hint')}',
                  icon: Icons.shopping_cart_outlined,
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.sizeOf(context).width <
                          AppSpacing.breakpointCompact
                      ? AppSpacing.sm
                      : AppSpacing.md,
                ),
                itemCount: controller.cart.length,
                itemBuilder: (_, i) {
                  final device = controller.cart[i];
                  return _DeviceCartCard(
                    controller: controller,
                    device: device,
                    tr: tr,
                  );
                },
              );
            }),
          ),
          _OrderSummaryBar(controller: controller, tr: tr),
        ],
      ),
    );
  }
}

class _DeviceCartCard extends StatelessWidget {
  const _DeviceCartCard({
    required this.controller,
    required this.device,
    required this.tr,
  });

  final OrdersController controller;
  final InventoryDeviceEntity device;
  final String Function(String key, [String? fallback]) tr;

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      device.deviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (device.barcode.isNotEmpty)
                      Text(
                        '${tr('barcode')}: ${device.barcode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    if (device.serialNumber1.isNotEmpty)
                      Text(
                        'SN1: ${device.serialNumber1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    Text(
                      '${tr('condition')}: ${device.condition.name}  •  ${device.storage}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => controller.removeFromCart(device.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: tr('selling_price'),
              prefixIcon: const Icon(Icons.attach_money),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              final price = double.tryParse(v) ?? 0.0;
              controller.setSellingPrice(device.id, price);
            },
          ),
        ],
      ),
    );
  }
}

class _BarcodeInputBar extends StatelessWidget {
  const _BarcodeInputBar({required this.controller, required this.tr});

  final OrdersController controller;
  final String Function(String key, [String? fallback]) tr;

  static bool get _isMobilePlatform {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      controller.handleBarcodeScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < AppSpacing.breakpointCompact;

    return Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      child: KeyboardListener(
        focusNode: controller.barcodeKeyListenerNode,
        onKeyEvent: _onKeyEvent,
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => TextField(
                  controller: controller.barcodeTextController,
                  focusNode: controller.barcodeFocusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.none,
                  decoration: InputDecoration(
                    labelText: tr('scan_barcode'),
                    hintText: tr('scan_device'),
                    prefixIcon: controller.scanningBarcode.value
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.qr_code_scanner),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => controller.handleBarcodeScan(),
                ),
              ),
            ),
            if (_isMobilePlatform) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                width: 48,
                child: Material(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _openCameraScanner(context),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              width: 48,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => controller.handleBarcodeScan(),
                  child: const Icon(Icons.add, color: AppColors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCameraScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    tr('scan_qr', 'Scan QR / Barcode'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final code = barcodes.first.rawValue;
                    if (code != null && code.isNotEmpty) {
                      Navigator.of(ctx).pop();
                      controller.handleQrScan(code);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom bar with order type, totals, and place-order button.
class _OrderSummaryBar extends StatelessWidget {
  const _OrderSummaryBar({required this.controller, required this.tr});

  final OrdersController controller;
  final String Function(String key, [String? fallback]) tr;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < AppSpacing.breakpointCompact;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      color: AppColors.surface,
      child: Column(
        children: [
          Obx(() {
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: Text(tr('cash')),
                  selected: controller.orderType.value == OrderType.cash,
                  onSelected: (_) =>
                      controller.orderType.value = OrderType.cash,
                ),
                ChoiceChip(
                  label: Text(tr('credit')),
                  selected: controller.orderType.value == OrderType.credit,
                  onSelected: (_) =>
                      controller.orderType.value = OrderType.credit,
                ),
                ChoiceChip(
                  label: Text(tr('bank_transfer')),
                  selected:
                      controller.orderType.value == OrderType.bankTransfer,
                  onSelected: (_) =>
                      controller.orderType.value = OrderType.bankTransfer,
                ),
                ChoiceChip(
                  label: Text(tr('e_wallet')),
                  selected: controller.orderType.value == OrderType.eWallet,
                  onSelected: (_) =>
                      controller.orderType.value = OrderType.eWallet,
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('subtotal')),
                Text(
                  LocaleFormat.currency(controller.subtotal, context),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            );
          }),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('tax')),
                Text(
                  LocaleFormat.currency(controller.taxAmount, context),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            );
          }),
          const Divider(),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('total'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  LocaleFormat.currency(controller.total, context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final placing = controller.placingOrder.value;
              return ElevatedButton(
                onPressed: placing
                    ? null
                    : () async {
                        final ok = await controller.placeOrder();
                        if (ok) {
                          Get.find<MainController>().goTo(AppRoutes.orders);
                        }
                      },
                child: placing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(tr('place_order')),
              );
            }),
          ),
        ],
      ),
    );
  }
}
