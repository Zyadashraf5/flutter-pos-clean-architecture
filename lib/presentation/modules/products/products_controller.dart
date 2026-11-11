import 'dart:io' show Directory, File;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/auth/permission.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/category/get_categories.dart';
import '../../../domain/usecases/order/get_orders.dart';
import '../../../domain/usecases/product/create_product.dart';
import '../../../domain/usecases/product/delete_product.dart';
import '../../../domain/usecases/product/get_product_by_barcode.dart';
import '../../../domain/usecases/product/get_products.dart';
import '../../../domain/usecases/product/update_product.dart';
import '../../auth/auth_controller.dart';

class ProductsController extends GetxController {
  ProductsController(
    this._getProducts,
    this._getCategories,
    this._createProduct,
    this._updateProduct,
    this._deleteProduct,
    this._getOrders,
    this._getProductByBarcode,
  );

  final GetProducts _getProducts;
  final GetCategories _getCategories;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final GetOrders _getOrders;
  final GetProductByBarcode _getProductByBarcode;

  final products = <ProductEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final loading = false.obs;
  final filterCategoryId = Rx<String?>(null);
  final searchQuery = ''.obs;
  final editProductId = Rxn<String>();
  final formCategoryId = Rx<String?>(null);

  // ── Selection state ──────────────────────────────────────────────
  final selectedIds = <String>{}.obs;
  final selectMode = false.obs;

  @override
  void onReady() {
    loadCategories();
    loadProducts();
    super.onReady();
  }

  Future<void> loadProducts() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.viewProducts)) return;
    loading.value = true;
    try {
      final list = await _getProducts(categoryId: filterCategoryId.value);
      products.assignAll(list);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadCategories() async {
    final list = await _getCategories();
    categories.assignAll(list);
  }

  List<ProductEntity> get filteredProducts {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.barcode.toLowerCase().contains(q))
        .toList();
  }

  Future<bool> saveProduct({
    String? id,
    required String name,
    required String categoryId,
    required double purchasePrice,
    required double sellingPrice,
    required int quantity,
    required double taxPercent,
    required String barcode,
  }) async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageProducts)) return false;
    if (name.trim().isEmpty || categoryId.isEmpty) return false;
    try {
      final uid = Get.find<AuthController>().currentUser.value?.uid;
      final entity = ProductEntity(
        id: id ?? _generateId(),
        name: name.trim(),
        categoryId: categoryId,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        quantity: quantity,
        taxPercent: taxPercent,
        barcode: barcode.trim(),
        createdByUid: id == null || id.isEmpty ? uid : null,
        updatedByUid: (id != null && id.isNotEmpty) ? uid : null,
      );
      if (id != null && id.isNotEmpty) {
        await _updateProduct(entity);
      } else {
        await _createProduct(entity);
      }
      await loadProducts();
      return true;
    } catch (_) {
      return false;
    }
  }

  final deleting = false.obs;

  Future<bool> deleteProduct(String id) async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageProducts)) {
      Get.snackbar(_tr('error'), _tr('no_permission'));
      return false;
    }
    if (deleting.value) return false;
    deleting.value = true;
    try {
      final orders = await _getOrders();
      final linked = orders.any(
        (o) => o.items.any((item) => item.productId == id),
      );
      if (linked) {
        Get.snackbar(
          _tr('cannot_delete'),
          _tr('product_linked_to_orders'),
        );
        return false;
      }
      await _deleteProduct(id);
      selectedIds.remove(id);
      await loadProducts();
      Get.snackbar(_tr('success'), _tr('product_deleted'));
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[ProductsCtrl] deleteProduct error: $e');
      Get.snackbar(_tr('error'), '${_tr('delete_failed')}: $e');
      return false;
    } finally {
      deleting.value = false;
    }
  }

  Future<bool> isBarcodeUnique(String barcode, {String? excludeProductId}) async {
    if (barcode.trim().isEmpty) return true;
    try {
      final existing = await _getProductByBarcode(barcode.trim());
      if (existing == null) return true;
      if (excludeProductId != null && existing.id == excludeProductId) return true;
      return false;
    } catch (_) {
      return true;
    }
  }

  // ── QR download (controller-level, no widget dependency) ────────

  Future<String?> downloadQrImage(String qrData) async {
    try {
      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: true,
      );
      final image = await painter.toImage(600);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final dir = Directory.systemTemp;
      final fileName =
          'qr_product_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      Get.snackbar(
        _tr('downloaded'),
        'QR saved: ${file.path}',
        duration: const Duration(seconds: 5),
      );
      return file.path;
    } catch (e) {
      if (kDebugMode) debugPrint('[ProductsCtrl] downloadQrImage error: $e');
      Get.snackbar(_tr('error'), 'Download failed: $e');
      return null;
    }
  }

  /// Downloads QR from a RepaintBoundary key (fallback for widget-rendered QR).
  Future<String?> downloadQrFromBoundary(GlobalKey qrKey) async {
    try {
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final dir = Directory.systemTemp;
      final fileName =
          'qr_product_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      Get.snackbar(
        _tr('downloaded'),
        'QR saved: ${file.path}',
        duration: const Duration(seconds: 5),
      );
      return file.path;
    } catch (e) {
      if (kDebugMode) debugPrint('[ProductsCtrl] downloadQrBoundary error: $e');
      Get.snackbar(_tr('error'), 'Download failed: $e');
      return null;
    }
  }

  // ── Auto barcode generation ──────────────────────────────────────

  Future<String> generateUniqueBarcode() async {
    final rng = Random();
    for (int attempt = 0; attempt < 10; attempt++) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final suffix = rng.nextInt(900) + 100;
      final barcode = 'BAR${ts % 100000000}$suffix';
      final unique = await isBarcodeUnique(barcode);
      if (unique) return barcode;
    }
    return 'BAR${DateTime.now().microsecondsSinceEpoch}';
  }

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
    selectedIds.assignAll(filteredProducts.map((p) => p.id));
    selectMode.value = true;
  }

  void deselectAll() {
    selectedIds.clear();
    selectMode.value = false;
  }

  bool isSelected(String id) => selectedIds.contains(id);

  int get selectedCount => selectedIds.length;

  Future<void> deleteSelected() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageProducts)) {
      Get.snackbar(_tr('error'), _tr('no_permission'));
      return;
    }
    final ids = selectedIds.toList();
    final orders = await _getOrders();
    int deleted = 0;
    int skipped = 0;
    for (final id in ids) {
      final linked = orders.any(
        (o) => o.items.any((item) => item.productId == id),
      );
      if (linked) {
        skipped++;
        continue;
      }
      try {
        await _deleteProduct(id);
        deleted++;
      } catch (e) {
        if (kDebugMode) debugPrint('[ProductsCtrl] bulk delete error: $e');
      }
    }
    deselectAll();
    await loadProducts();
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

  String _generateId() => 'prod_${DateTime.now().millisecondsSinceEpoch}';
}
