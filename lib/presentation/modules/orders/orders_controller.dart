import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/auth/permission.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/inventory/get_inventory_device_by_barcode.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/order/create_order.dart';
import '../../../domain/usecases/order/delete_order.dart';
import '../../../domain/usecases/order/get_orders.dart';
import '../../../domain/usecases/settings/get_default_tax.dart';
import '../../auth/auth_controller.dart';

class OrdersController extends GetxController {
  OrdersController(
    this._getOrders,
    this._getDeviceByBarcode,
    this._getDevices,
    this._getDefaultTax,
    this._createOrder,
    this._deleteOrder,
  );

  final GetOrders _getOrders;
  final GetInventoryDeviceByBarcode _getDeviceByBarcode;
  final GetInventoryDevices _getDevices;
  final GetDefaultTax _getDefaultTax;
  final CreateOrder _createOrder;
  final DeleteOrder _deleteOrder;

  final orders = <OrderEntity>[].obs;
  final loading = false.obs;
  final placingOrder = false.obs;

  /// Cart holds unique devices (each device can only appear once).
  final cart = <InventoryDeviceEntity>[].obs;
  final orderType = OrderType.cash.obs;
  final defaultTaxPercent = 0.0.obs;

  /// Per-device selling prices entered by the user.
  final sellingPrices = <String, double>{}.obs;

  // ── Barcode scanner ──────────────────────────────────────────────
  final barcodeTextController = TextEditingController();
  final barcodeFocusNode = FocusNode();
  final barcodeKeyListenerNode = FocusNode(skipTraversal: true);
  bool _scannerBusy = false;

  // ── Selection state ──────────────────────────────────────────────
  final selectedIds = <String>{}.obs;
  final selectMode = false.obs;

  @override
  void onReady() {
    loadOrders();
    _loadDefaultTax();
    super.onReady();
  }

  @override
  void onClose() {
    barcodeTextController.dispose();
    barcodeFocusNode.dispose();
    barcodeKeyListenerNode.dispose();
    super.onClose();
  }

  // ── Orders ───────────────────────────────────────────────────────

  Future<void> loadOrders() async {
    loading.value = true;
    try {
      orders.assignAll(await _getOrders());
    } catch (e) {
      if (kDebugMode) debugPrint('[OrdersCtrl] loadOrders error: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadDefaultTax() async {
    try {
      defaultTaxPercent.value = await _getDefaultTax();
    } catch (e) {
      if (kDebugMode) debugPrint('[OrdersCtrl] loadDefaultTax error: $e');
    }
  }

  // ── Delete order (admin only) ────────────────────────────────────

  final deleting = false.obs;

  Future<bool> deleteOrder(String orderId) async {
    final auth = Get.find<AuthController>();
    if (!auth.hasPermissionEnum(Permission.deleteOrder)) {
      Get.snackbar(_tr('error'), _tr('no_permission'));
      return false;
    }
    if (deleting.value) return false;
    deleting.value = true;
    try {
      await _deleteOrder(orderId);
      selectedIds.remove(orderId);
      await loadOrders();
      Get.snackbar(_tr('success'), _tr('order_deleted'));
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[OrdersCtrl] deleteOrder error: $e');
      Get.snackbar(_tr('error'), '${_tr('delete_failed')}: $e');
      return false;
    } finally {
      deleting.value = false;
    }
  }

  bool get canDeleteOrders =>
      Get.find<AuthController>().hasPermissionEnum(Permission.deleteOrder);

  // ── Selection ────────────────────────────────────────────────────

  void toggleSelect(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    selectMode.value = selectedIds.isNotEmpty;
  }

  void selectAll() {
    selectedIds.assignAll(orders.map((o) => o.id));
    selectMode.value = true;
  }

  void deselectAll() {
    selectedIds.clear();
    selectMode.value = false;
  }

  bool isSelected(String id) => selectedIds.contains(id);

  int get selectedCount => selectedIds.length;

  Future<void> deleteSelected() async {
    if (!canDeleteOrders) {
      Get.snackbar(_tr('error'), _tr('no_permission'));
      return;
    }
    final ids = selectedIds.toList();
    int deleted = 0;
    for (final id in ids) {
      try {
        await _deleteOrder(id);
        deleted++;
      } catch (e) {
        if (kDebugMode) debugPrint('[OrdersCtrl] bulk delete error: $e');
      }
    }
    deselectAll();
    await loadOrders();
    Get.snackbar(_tr('bulk_delete'), '$deleted ${_tr('deleted')}');
  }

  // ── Barcode scan entry-point (called by Enter key AND + button) ─

  final scanningBarcode = false.obs;

  Future<void> handleBarcodeScan() async {
    final barcode = barcodeTextController.text.trim();
    barcodeTextController.clear();
    _refocusBarcodeField();
    if (barcode.isEmpty || _scannerBusy) return;

    _scannerBusy = true;
    scanningBarcode.value = true;
    try {
      await _addDeviceByQuery(barcode);
    } finally {
      _scannerBusy = false;
      scanningBarcode.value = false;
    }
  }

  /// Handles data from a QR code scan (camera). Decodes JSON to extract
  /// barcode, or falls back to using the raw string as a barcode.
  Future<void> handleQrScan(String rawData) async {
    if (_scannerBusy) return;
    _scannerBusy = true;
    scanningBarcode.value = true;
    try {
      String? barcode;
      try {
        final json = jsonDecode(rawData) as Map<String, dynamic>;
        barcode = json['barcode'] as String?;
      } catch (_) {}
      barcode ??= rawData.trim();
      if (barcode.isEmpty) return;
      await _addDeviceByQuery(barcode);
    } finally {
      _scannerBusy = false;
      scanningBarcode.value = false;
    }
  }

  void _refocusBarcodeField() {
    Future.microtask(() {
      if (!barcodeFocusNode.hasFocus) {
        barcodeFocusNode.requestFocus();
      }
    });
  }

  /// Searches inventory_devices by barcode, serial numbers, then device name.
  Future<void> _addDeviceByQuery(String query) async {
    // 1) Try barcode lookup
    InventoryDeviceEntity? device = await _getDeviceByBarcode(query);

    // 2) Fallback: search by serial numbers or device name
    if (device == null) {
      try {
        final allDevices = await _getDevices();
        final q = query.toLowerCase();
        device = allDevices.firstWhereOrNull(
          (d) =>
              d.serialNumber1.toLowerCase() == q ||
              d.serialNumber2.toLowerCase() == q,
        );
        device ??= allDevices.firstWhereOrNull(
          (d) => d.deviceName.toLowerCase() == q,
        );
        device ??= allDevices.firstWhereOrNull(
          (d) => d.deviceName.toLowerCase().contains(q),
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[OrdersCtrl] device search error: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('Search query: $query, found device: ${device?.deviceName}');
    }
    if (device == null) {
      Get.snackbar(_tr('not_found'), _tr('no_device_barcode'));
      return;
    }

    // Prevent adding a device that is already sold
    if (device.isSold) {
      Get.snackbar(_tr('already_sold'), device.deviceName);
      return;
    }

    // Prevent adding the same device twice
    if (cart.any((d) => d.id == device!.id)) {
      Get.snackbar(_tr('already_in_cart'), device.deviceName);
      return;
    }

    cart.add(device);
  }

  Future<void> addDeviceByBarcode(String barcode) async {
    final b = barcode.trim();
    if (b.isEmpty) return;
    barcodeTextController.clear();
    _refocusBarcodeField();
    await _addDeviceByQuery(b);
  }

  String _tr(String key) {
    final ctx = Get.context;
    if (ctx != null) {
      return AppLocalizations.of(ctx)?.tr(key) ?? key;
    }
    return key;
  }

  void removeFromCart(String deviceId) {
    cart.removeWhere((d) => d.id == deviceId);
    sellingPrices.remove(deviceId);
  }

  void clearCart() {
    cart.clear();
    sellingPrices.clear();
  }

  /// Set selling price for a device in the cart.
  void setSellingPrice(String deviceId, double price) {
    sellingPrices[deviceId] = price;
    sellingPrices.refresh();
  }

  /// Get selling price for a device, defaults to 0 if not set.
  double getSellingPrice(String deviceId) {
    return sellingPrices[deviceId] ?? 0.0;
  }

  double get subtotal {
    double s = 0;
    for (final d in cart) {
      s += getSellingPrice(d.id);
    }
    return _safe(s);
  }

  double get taxAmount {
    double t = 0;
    for (final d in cart) {
      final price = getSellingPrice(d.id);
      t += price * (defaultTaxPercent.value / 100);
    }
    return _safe(t);
  }

  double get total => _safe(subtotal + taxAmount);

  Future<bool> placeOrder() async {
    final auth = Get.find<AuthController>();
    if (!auth.hasPermissionEnum(Permission.createOrder)) {
      Get.snackbar('Error', _tr('no_permission'));
      return false;
    }
    if (cart.isEmpty) {
      Get.snackbar('Error', _tr('empty_cart'));
      return false;
    }

    // Validate all selling prices are set
    for (final d in cart) {
      if (getSellingPrice(d.id) <= 0) {
        Get.snackbar(_tr('error'), '${_tr('price_required')}: ${d.deviceName}');
        return false;
      }
    }

    if (placingOrder.value) return false;
    placingOrder.value = true;

    try {
      final sub = subtotal;
      final tax = taxAmount;
      final tot = total;

      if (kDebugMode) {
        debugPrint(
          '[OrdersCtrl] placeOrder: sub=$sub, tax=$tax, total=$tot, devices=${cart.length}',
        );
      }

      final items = cart
          .map(
            (d) => OrderItemEntity(
              productId: d.id,
              productName: d.deviceName,
              quantity: 1,
              unitPrice: _safe(getSellingPrice(d.id)),
              taxPercent: _safe(defaultTaxPercent.value),
              lineTotal: _safe(
                getSellingPrice(d.id) * (1 + defaultTaxPercent.value / 100),
              ),
            ),
          )
          .toList();

      final u = auth.currentUser.value;
      final order = OrderEntity(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        items: items,
        orderType: orderType.value,
        subtotal: sub,
        taxAmount: tax,
        total: tot,
        createdAt: DateTime.now(),
        createdByUid: u?.uid,
        createdByName: u?.name,
        createdByEmail: u?.email,
      );

      await _createOrder(order);
      clearCart();

      Get.snackbar(_tr('success'), _tr('order_success'));

      await loadOrders();
      return true;
    } on OrderValidationException catch (e) {
      Get.snackbar(_tr('error'), e.message);
      return false;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[OrdersCtrl] placeOrder EXCEPTION: $e');
        debugPrint(st.toString());
      }
      Get.snackbar(_tr('error'), '${_tr('order_failed')}: $e');
      return false;
    } finally {
      placingOrder.value = false;
    }
  }

  static double _safe(double v) => v.isFinite ? v : 0.0;
}
