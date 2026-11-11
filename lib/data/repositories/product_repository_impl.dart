import 'package:flutter/foundation.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/firebase/firebase_product_datasource.dart';
import '../datasources/firebase/firebase_product_firestore_datasource.dart';
import '../datasources/local/product_local_datasource.dart';
import '../models/product_model.dart';
import '../models/firestore/product_firestore_model.dart';
import '../../core/utils/app_logger.dart';

/// Reads from Firestore first so seeded/remote data is visible. Writes to both local and Firestore.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._local, {
    FirebaseProductDataSource? remote,
    FirebaseProductFirestoreDataSource? firestoreRead,
  }) : _remote = remote,
       _firestoreRead = firestoreRead;

  final ProductLocalDatasource _local;
  final FirebaseProductDataSource? _remote;
  final FirebaseProductFirestoreDataSource? _firestoreRead;

  @override
  Future<List<ProductEntity>> getAll() async {
    if (_firestoreRead != null) {
      try {
        final list = await _firestoreRead.getAll();
        AppLogger.repository(
          'Product',
          'getAll() from Firestore: ${list.length} items',
        );
        return list.map(_firestoreModelToEntity).toList();
      } catch (e, st) {
        if (kDebugMode) {
          AppLogger.repository(
            'Product',
            'getAll() Firestore failed, fallback to local',
            e,
          );
          debugPrint(st.toString());
        }
      }
    }
    final local = await _local.getAll();
    AppLogger.repository(
      'Product',
      'getAll() from local: ${local.length} items',
    );
    return local;
  }

  @override
  Future<List<ProductEntity>> getByCategoryId(String categoryId) async {
    final all = await getAll();
    return all.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<ProductEntity?> getById(String id) async {
    if (_firestoreRead != null) {
      try {
        final model = await _firestoreRead.getById(id);
        if (model != null) return _firestoreModelToEntity(model);
      } catch (_) {}
    }
    return _local.getById(id);
  }

  @override
  Future<ProductEntity?> getByBarcode(String barcode) async {
    if (_firestoreRead != null) {
      try {
        final model = await _firestoreRead.getByBarcode(barcode);
        print('getByBarcode: Firestore returned model: $model');
        if (model != null) return _firestoreModelToEntity(model);
      } catch (_) {}
    }
    return _local.getByBarcode(barcode);
  }

  @override
  Future<void> create(ProductEntity entity) async {
    final model = ProductModel.fromEntity(entity);
    await _local.create(model);
    await _remote?.create(model);
  }

  @override
  Future<void> update(ProductEntity entity) async {
    final model = ProductModel.fromEntity(entity);
    await _local.update(model);
    await _remote?.update(model);
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    await _remote?.delete(id);
  }

  @override
  Future<void> decreaseStock(String productId, int quantity) async {
    final product = await getById(productId);
    if (product == null) return;
    final newQty = (product.quantity - quantity).clamp(0, product.quantity);
    final updated = ProductModel(
      id: product.id,
      name: product.name,
      categoryId: product.categoryId,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      quantity: newQty,
      taxPercent: product.taxPercent,
      barcode: product.barcode,
    );
    await _local.update(updated);
    try {
      await _remote?.update(updated);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepo] decreaseStock Firestore write failed: $e');
      }
    }
  }

  @override
  Future<void> increaseStock(
    String productId,
    int quantity, {
    double? purchasePrice,
  }) async {
    if (quantity <= 0) return;
    final product = await getById(productId);
    if (product == null) return;
    final newQty = product.quantity + quantity;
    double newPurchasePrice = product.purchasePrice;
    if (purchasePrice != null && purchasePrice > 0) {
      newPurchasePrice =
          (product.quantity * product.purchasePrice +
              quantity * purchasePrice) /
          newQty;
    }
    final updated = ProductModel(
      id: product.id,
      name: product.name,
      categoryId: product.categoryId,
      purchasePrice: newPurchasePrice,
      sellingPrice: product.sellingPrice,
      quantity: newQty,
      taxPercent: product.taxPercent,
      barcode: product.barcode,
    );
    await _local.update(updated);
    try {
      await _remote?.update(updated);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepo] increaseStock Firestore write failed: $e');
      }
    }
  }

  ProductEntity _firestoreModelToEntity(ProductFirestoreModel m) {
    print('Mapping Firestore model to entity: $m');
    return ProductEntity(
      id: m.id,
      name: m.name,
      categoryId: m.categoryId,
      purchasePrice: m.purchasePrice,
      sellingPrice: m.sellingPrice,
      quantity: m.quantity,
      taxPercent: m.taxPercentage,
      barcode: m.barcode,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      isActive: m.isActive,
      createdByUid: m.createdByUid,
      updatedByUid: m.updatedByUid,
    );
  }
}
