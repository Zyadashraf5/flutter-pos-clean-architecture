import 'package:cashiere_system/domain/entities/purchase_entity.dart';
import 'package:cashiere_system/domain/usecases/purchase/create_purchase.dart';
import 'package:cashiere_system/domain/usecases/supplier/record_supplier_payment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

PurchaseEntity purchase({
  PurchaseType type = PurchaseType.cash,
  List<PurchaseItemEntity>? items,
  double total = 500,
  double paid = 500,
  double remaining = 0,
}) {
  return PurchaseEntity(
    id: 'purchase-1',
    supplierId: 'supplier-1',
    supplierName: 'Supplier',
    purchaseType: type,
    items: items ??
        const [
          PurchaseItemEntity(productId: 'p1', productName: 'Cable', quantity: 10, purchasePrice: 20),
          PurchaseItemEntity(productId: 'p2', productName: 'Charger', quantity: 5, purchasePrice: 60),
        ],
    totalAmount: total,
    paidAmount: paid,
    remainingAmount: remaining,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late CallLog log;
  late FakePurchaseRepository purchases;
  late FakeProductRepository products;
  late FakeSupplierRepository suppliers;
  late FakeFinancialRepository financial;
  late CreatePurchase createPurchase;

  setUp(() {
    log = CallLog();
    purchases = FakePurchaseRepository(log);
    products = FakeProductRepository(log);
    suppliers = FakeSupplierRepository(log);
    financial = FakeFinancialRepository(log);
    createPurchase = CreatePurchase(purchases, products, suppliers, financial);
  });

  group('CreatePurchase', () {
    test('an empty purchase is ignored', () async {
      await createPurchase(purchase(items: const []));
      expect(log.calls, isEmpty);
    });

    test('the purchase is persisted before stock is increased', () async {
      await createPurchase(purchase());

      expect(log.calls.first, 'purchase.create');
      expect(products.stockAdded, {'p1': 10, 'p2': 5});
      expect(products.lastPurchasePrice, {'p1': 20, 'p2': 60});
    });

    test('a failed save does not change stock or debt', () async {
      purchases.createError = StateError('offline');

      await expectLater(
        createPurchase(purchase(type: PurchaseType.credit, paid: 100, remaining: 400)),
        throwsA(isA<StateError>()),
      );

      expect(log.calls, ['purchase.create']);
      expect(products.stockAdded, isEmpty);
      expect(suppliers.debt, isEmpty);
      expect(financial.supplierDebt, 0);
    });

    test('a cash purchase creates no supplier debt', () async {
      await createPurchase(purchase());
      expect(suppliers.debt, isEmpty);
      expect(financial.supplierDebt, 0);
    });

    test('a credit purchase records the unpaid remainder as debt', () async {
      await createPurchase(purchase(type: PurchaseType.credit, paid: 100, remaining: 400));

      expect(suppliers.debt, {'supplier-1': 400});
      expect(financial.supplierDebt, 400);
    });
  });

  group('RecordSupplierPayment', () {
    late RecordSupplierPayment pay;

    setUp(() => pay = RecordSupplierPayment(suppliers, financial));

    test('ignores zero and negative amounts', () async {
      await pay('supplier-1', 0);
      await pay('supplier-1', -50);
      expect(log.calls, isEmpty);
    });

    test('records the payment and reduces outstanding supplier debt', () async {
      financial.supplierDebt = 400;

      await pay('supplier-1', 150);

      expect(suppliers.paid, {'supplier-1': 150});
      expect(financial.supplierDebt, 250);
    });
  });
}
