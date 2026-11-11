import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/auth/permission.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../domain/entities/supplier_entity.dart';
import '../../../domain/usecases/purchase/get_purchases.dart';
import '../../../domain/usecases/supplier/create_supplier.dart';
import '../../../domain/usecases/supplier/delete_supplier.dart';
import '../../../domain/usecases/supplier/get_suppliers.dart';
import '../../../domain/usecases/supplier/record_supplier_payment.dart';
import '../../../domain/usecases/supplier/update_supplier.dart';
import '../../auth/auth_controller.dart';

class SuppliersController extends GetxController {
  SuppliersController(
    this._getSuppliers,
    this._recordPayment,
    this._getPurchases,
    this._deleteSupplier,
    this._createSupplier,
    this._updateSupplier,
  );

  final GetSuppliers _getSuppliers;
  final RecordSupplierPayment _recordPayment;
  final GetPurchases _getPurchases;
  final DeleteSupplier _deleteSupplier;
  final CreateSupplier _createSupplier;
  final UpdateSupplier _updateSupplier;

  final suppliers = <SupplierEntity>[].obs;
  final purchases = <PurchaseEntity>[].obs;
  final loading = false.obs;

  // ── Form state ────────────────────────────────────────────────────
  final editSupplierId = Rxn<String>();

  // ── Selection state ───────────────────────────────────────────────
  final selectedIds = <String>{}.obs;
  final selectMode = false.obs;

  @override
  void onReady() {
    loadSuppliers();
    loadPurchases();
    super.onReady();
  }

  Future<void> loadSuppliers() async {
    loading.value = true;
    try {
      suppliers.assignAll(await _getSuppliers());
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadPurchases() async {
    try {
      purchases.assignAll(await _getPurchases());
    } catch (_) {}
  }

  List<PurchaseEntity> purchasesForSupplier(String supplierId) {
    return purchases.where((p) => p.supplierId == supplierId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<bool> recordPayment(String supplierId, double amount) async {
    if (amount <= 0) return false;
    try {
      await _recordPayment(supplierId, amount);
      await loadSuppliers();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Save supplier (create or update) ──────────────────────────────

  final saving = false.obs;

  Future<bool> saveSupplier({
    String? id,
    required String name,
    String? phone,
  }) async {
    if (name.trim().isEmpty) return false;
    if (saving.value) return false;
    saving.value = true;
    try {
      final isEdit = id != null && id.isNotEmpty;

      final existing = isEdit
          ? suppliers.firstWhereOrNull((s) => s.id == id)
          : null;

      final entity = SupplierEntity(
        id: isEdit ? id : 'sup_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
        totalDebt: existing?.totalDebt ?? 0,
        totalPaid: existing?.totalPaid ?? 0,
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEdit) {
        await _updateSupplier(entity);
      } else {
        await _createSupplier(entity);
      }
      await loadSuppliers();
      Get.snackbar(
        _tr('success'),
        isEdit ? _tr('supplier_updated') : _tr('supplier_created'),
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[SuppliersCtrl] saveSupplier error: $e');
      Get.snackbar(_tr('error'), '${_tr('save_failed')}: $e');
      return false;
    } finally {
      saving.value = false;
    }
  }

  // ── Delete supplier (admin only) ────────────────────────────────

  final deleting = false.obs;

  bool get canDeleteSupplier =>
      Get.find<AuthController>().hasPermissionEnum(Permission.deleteSupplier);

  Future<bool> deleteSupplier(String supplierId) async {
    if (!canDeleteSupplier) {
      Get.snackbar(_tr('error'), _tr('no_permission'));
      return false;
    }
    if (deleting.value) return false;
    deleting.value = true;
    try {
      final linked = purchases.any((p) => p.supplierId == supplierId);
      if (linked) {
        Get.snackbar(
          _tr('cannot_delete'),
          _tr('supplier_has_purchases'),
        );
        return false;
      }
      await _deleteSupplier(supplierId);
      selectedIds.remove(supplierId);
      await loadSuppliers();
      Get.snackbar(_tr('success'), _tr('supplier_deleted'));
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[SuppliersCtrl] deleteSupplier error: $e');
      Get.snackbar(_tr('error'), '${_tr('delete_failed')}: $e');
      return false;
    } finally {
      deleting.value = false;
    }
  }

  // ── Selection ─────────────────────────────────────────────────────

  void toggleSelect(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    selectMode.value = selectedIds.isNotEmpty;
  }

  void selectAll() {
    selectedIds.assignAll(suppliers.map((s) => s.id));
    selectMode.value = true;
  }

  void deselectAll() {
    selectedIds.clear();
    selectMode.value = false;
  }

  bool isSelected(String id) => selectedIds.contains(id);

  int get selectedCount => selectedIds.length;

  Future<void> deleteSelected() async {
    if (!canDeleteSupplier) {
      Get.snackbar(_tr('error'), _tr('no_permission'));
      return;
    }
    final ids = selectedIds.toList();
    int deleted = 0;
    int skipped = 0;
    for (final id in ids) {
      final linked = purchases.any((p) => p.supplierId == id);
      if (linked) {
        skipped++;
        continue;
      }
      try {
        await _deleteSupplier(id);
        deleted++;
      } catch (e) {
        if (kDebugMode) debugPrint('[SuppliersCtrl] bulk delete error: $e');
      }
    }
    deselectAll();
    await loadSuppliers();
    final msg = '$deleted ${_tr('deleted')}';
    final skipMsg = skipped > 0 ? ', $skipped ${_tr('skipped_linked')}' : '';
    Get.snackbar(_tr('bulk_delete'), '$msg$skipMsg');
  }

  String _tr(String key) {
    final ctx = Get.context;
    if (ctx != null) {
      return AppLocalizations.of(ctx)?.tr(key) ?? key;
    }
    return key;
  }
}
