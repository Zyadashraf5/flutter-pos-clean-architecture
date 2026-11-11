import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/auth/permission.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../domain/entities/supplier_entity.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/purchase/create_purchase.dart';
import '../../../domain/usecases/supplier/create_supplier.dart';
import '../../../domain/usecases/supplier/get_suppliers.dart';
import '../../auth/auth_controller.dart';

class PurchaseLine {
  PurchaseLine({
    this.productId,
    this.productName,
    required this.quantity,
    required this.purchasePrice,
  });
  String? productId;
  String? productName;
  int quantity;
  double purchasePrice;
  double get lineTotal => quantity * purchasePrice;
}

class PurchaseCreateController extends GetxController {
  PurchaseCreateController(
    this._getSuppliers,
    this._getDevices,
    this._createSupplier,
    this._createPurchase,
  );

  final GetSuppliers _getSuppliers;
  final GetInventoryDevices _getDevices;
  final CreateSupplier _createSupplier;
  final CreatePurchase _createPurchase;

  final suppliers = <SupplierEntity>[].obs;
  final devices = <InventoryDeviceEntity>[].obs;
  final lines = <PurchaseLine>[].obs;
  final loading = false.obs;
  final submitting = false.obs;

  final selectedSupplierId = Rx<String?>(null);
  final newSupplierName = ''.obs;
  final purchaseType = PurchaseType.cash.obs;
  final paidAmount = 0.0.obs;

  @override
  void onReady() {
    loadSuppliers();
    loadDevices();
    super.onReady();
  }

  Future<void> loadSuppliers() async {
    suppliers.assignAll(await _getSuppliers());
  }

  Future<void> loadDevices() async {
    devices.assignAll(await _getDevices());
  }

  void addLine() {
    lines.add(PurchaseLine(quantity: 1, purchasePrice: 0));
  }

  void removeLine(int index) {
    if (index >= 0 && index < lines.length) lines.removeAt(index);
  }

  double get totalAmount {
    double sum = 0;
    for (final line in lines) {
      sum += line.lineTotal;
    }
    return sum;
  }

  double get remainingAmount {
    final total = totalAmount;
    final paid = purchaseType.value == PurchaseType.credit
        ? paidAmount.value
        : total;
    return total - paid;
  }

  Future<bool> submit() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.updateStock))
      return false;
    if (lines.isEmpty) return false;
    final validLines = lines
        .where(
          (l) => l.productId != null && l.quantity > 0 && l.purchasePrice >= 0,
        )
        .toList();
    if (validLines.isEmpty) return false;

    String supplierId = selectedSupplierId.value ?? '';
    String supplierName = newSupplierName.value.trim();
    if (supplierName.isNotEmpty) {
      supplierId = const Uuid().v4();
      await _createSupplier(
        SupplierEntity(
          id: supplierId,
          name: supplierName,
          totalDebt: 0,
          totalPaid: 0,
        ),
      );
    } else {
      final sup = suppliers.where((s) => s.id == supplierId).firstOrNull;
      supplierName = sup?.name ?? '';
    }
    if (supplierName.isEmpty) return false;

    final total = totalAmount;
    final paid = purchaseType.value == PurchaseType.credit
        ? paidAmount.value
        : total;
    final remaining = total - paid;

    final purchase = PurchaseEntity(
      id: 'pur_${DateTime.now().millisecondsSinceEpoch}',
      supplierId: supplierId,
      supplierName: supplierName,
      purchaseType: purchaseType.value,
      items: validLines
          .map(
            (l) => PurchaseItemEntity(
              productId: l.productId!,
              productName: l.productName ?? '',
              quantity: l.quantity,
              purchasePrice: l.purchasePrice,
            ),
          )
          .toList(),
      totalAmount: total,
      paidAmount: paid,
      remainingAmount: remaining,
      createdAt: DateTime.now(),
    );

    submitting.value = true;
    try {
      await _createPurchase(purchase);
      return true;
    } finally {
      submitting.value = false;
    }
  }
}
