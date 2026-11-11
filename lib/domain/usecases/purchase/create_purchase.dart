import 'package:flutter/foundation.dart';

import '../../entities/purchase_entity.dart';
import '../../repositories/financial_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/supplier_repository.dart';

/// Creates a purchase: saves it first, then increases product stock (with a
/// weighted average purchase price) and, for credit purchases, records the
/// unpaid remainder as supplier debt and in the financial summary.
class CreatePurchase {
  CreatePurchase(
    this._purchaseRepository,
    this._productRepository,
    this._supplierRepository,
    this._financialRepository,
  );

  final PurchaseRepository _purchaseRepository;
  final ProductRepository _productRepository;
  final SupplierRepository _supplierRepository;
  final FinancialRepository _financialRepository;

  Future<void> call(PurchaseEntity purchase) async {
    if (purchase.items.isEmpty) return;

    // Persist the purchase first so stock and debt are only changed for a
    // purchase that actually exists.
    await _purchaseRepository.create(purchase);

    for (final item in purchase.items) {
      try {
        await _productRepository.increaseStock(
          item.productId,
          item.quantity,
          purchasePrice: item.purchasePrice,
        );
      } catch (e, st) {
        debugPrint('[CreatePurchase] increaseStock failed ${item.productId}: $e');
        debugPrint(st.toString());
      }
    }

    if (purchase.purchaseType == PurchaseType.credit && purchase.remainingAmount > 0) {
      try {
        await _supplierRepository.addDebt(purchase.supplierId, purchase.remainingAmount);
        await _financialRepository.addToSupplierDebt(purchase.remainingAmount);
      } catch (e, st) {
        debugPrint('[CreatePurchase] supplier/financial update failed: $e');
        debugPrint(st.toString());
      }
    }
  }
}
