import 'dart:math';

import 'package:get/get.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/auth/permission.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../../domain/usecases/category/get_categories.dart';
import '../../../domain/usecases/inventory/add_inventory_device.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/inventory/get_inventory_device_by_barcode.dart';
import '../../auth/auth_controller.dart';

class InventoryController extends GetxController {
  InventoryController(
    this._getCategories,
    this._addInventoryDevice,
    this._getInventoryDevices,
    this._getInventoryDeviceByBarcode,
  );

  final GetCategories _getCategories;
  final AddInventoryDevice _addInventoryDevice;
  final GetInventoryDevices _getInventoryDevices;
  final GetInventoryDeviceByBarcode _getInventoryDeviceByBarcode;

  final categories = <CategoryEntity>[].obs;
  final devices = <InventoryDeviceEntity>[].obs;
  final loading = false.obs;
  final savingDevice = false.obs;
  final searchQuery = ''.obs;
  final filterCategoryId = Rx<String?>(null);

  @override
  void onReady() {
    loadCategories();
    loadDevices();
    super.onReady();
  }

  Future<void> loadDevices() async {
    loading.value = true;
    try {
      final list = await _getInventoryDevices();
      devices.assignAll(list);
    } catch (_) {
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadCategories() async {
    final list = await _getCategories();
    categories.assignAll(list);
  }

  List<InventoryDeviceEntity> get filteredDevices {
    var list = devices.toList();
    final catId = filterCategoryId.value;
    if (catId != null && catId.isNotEmpty) {
      list = list.where((d) => d.categoryId == catId).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (d) =>
                d.deviceName.toLowerCase().contains(q) ||
                d.barcode.toLowerCase().contains(q) ||
                d.serialNumber1.toLowerCase().contains(q) ||
                d.serialNumber2.toLowerCase().contains(q) ||
                d.supplierName.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  double get totalInventoryValue {
    double sum = 0;
    for (final d in devices) {
      sum += d.receivingPrice;
    }
    return sum;
  }

  // ── Device inventory methods ─────────────────────────────────

  /// Generate a unique barcode for a device and verify it's not already used.
  Future<String> generateUniqueDeviceBarcode() async {
    final rng = Random();
    for (int attempt = 0; attempt < 10; attempt++) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final suffix = rng.nextInt(900) + 100;
      final barcode = 'DEV${ts % 100000000}$suffix';
      final existing = await _getInventoryDeviceByBarcode(barcode);
      if (existing == null) return barcode;
    }
    return 'DEV${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Save a new device to inventory.
  Future<bool> saveDevice(InventoryDeviceEntity device) async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.updateStock)) {
      Get.snackbar(_tr('error'), _tr('no_permission'));
      return false;
    }
    savingDevice.value = true;
    try {
      await _addInventoryDevice(device);
      await loadDevices();
      Get.snackbar(_tr('success'), _tr('device_added_success'));
      return true;
    } catch (e) {
      Get.snackbar(_tr('error'), '${_tr('device_add_failed')}: $e');
      return false;
    } finally {
      savingDevice.value = false;
    }
  }

  String categoryName(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return '';
    try {
      return categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return categoryId;
    }
  }

  String _tr(String key) {
    final ctx = Get.context;
    if (ctx != null) {
      return AppLocalizations.of(ctx)?.tr(key) ?? key;
    }
    return key;
  }
}
