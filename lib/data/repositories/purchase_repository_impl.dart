import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/firebase/firebase_purchase_datasource.dart';
import '../models/firestore/purchase_firestore_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(this._datasource);

  final FirebasePurchaseDataSource _datasource;

  @override
  Future<List<PurchaseEntity>> getAll() async {
    final list = await _datasource.getAllPurchasesWithItems();
    return list.map(_toEntity).toList();
  }

  @override
  Future<List<PurchaseEntity>> getByDateRange(DateTime start, DateTime end) async {
    final list = await _datasource.getPurchasesByDateRange(start, end);
    return list.map(_toEntity).toList();
  }

  @override
  Future<void> create(PurchaseEntity purchase) async {
    final model = PurchaseFirestoreModel(
      id: purchase.id,
      supplierId: purchase.supplierId,
      supplierName: purchase.supplierName,
      purchaseType: purchase.purchaseType == PurchaseType.credit
          ? PurchaseTypeFirestore.credit
          : PurchaseTypeFirestore.cash,
      totalAmount: purchase.totalAmount,
      paidAmount: purchase.paidAmount,
      remainingAmount: purchase.remainingAmount,
      createdAt: purchase.createdAt,
    );
    final items = purchase.items
        .map((e) => PurchaseItemFirestoreModel(
              productId: e.productId,
              productName: e.productName,
              quantity: e.quantity,
              purchasePrice: e.purchasePrice,
            ))
        .toList();
    await _datasource.createPurchaseWithItems(model, items);
  }

  PurchaseEntity _toEntity(PurchaseWithItems p) {
    final purchase = p.purchase;
    final type = purchase.purchaseType == PurchaseTypeFirestore.credit
        ? PurchaseType.credit
        : PurchaseType.cash;
    final items = p.items
        .map((e) => PurchaseItemEntity(
              productId: e.productId,
              productName: e.productName,
              quantity: e.quantity,
              purchasePrice: e.purchasePrice,
            ))
        .toList();
    return PurchaseEntity(
      id: purchase.id,
      supplierId: purchase.supplierId,
      supplierName: purchase.supplierName,
      purchaseType: type,
      items: items,
      totalAmount: purchase.totalAmount,
      paidAmount: purchase.paidAmount,
      remainingAmount: purchase.remainingAmount,
      createdAt: purchase.createdAt,
    );
  }
}
