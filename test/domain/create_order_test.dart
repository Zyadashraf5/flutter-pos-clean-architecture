import 'package:cashiere_system/domain/entities/inventory_device_entity.dart';
import 'package:cashiere_system/domain/entities/order_entity.dart';
import 'package:cashiere_system/domain/usecases/order/create_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

OrderItemEntity item({
  String productId = 'device-1',
  int quantity = 1,
  double unitPrice = 100,
  double taxPercent = 14,
  double? lineTotal,
}) {
  return OrderItemEntity(
    productId: productId,
    productName: 'Phone $productId',
    quantity: quantity,
    unitPrice: unitPrice,
    taxPercent: taxPercent,
    lineTotal: lineTotal ?? unitPrice * quantity,
  );
}

OrderEntity order(
  List<OrderItemEntity> items, {
  OrderType type = OrderType.cash,
  double subtotal = 0,
  double taxAmount = 0,
  double total = 0,
}) {
  return OrderEntity(
    id: 'order-1',
    items: items,
    orderType: type,
    subtotal: subtotal,
    taxAmount: taxAmount,
    total: total,
    createdAt: DateTime(2026, 1, 1),
  );
}

InventoryDeviceEntity device(String id) {
  return InventoryDeviceEntity(
    id: id,
    deviceName: 'Phone $id',
    barcode: 'BC-$id',
    serialNumber1: 'SN1-$id',
    serialNumber2: 'SN2-$id',
    condition: DeviceCondition.newDevice,
    color: 'Black',
    storage: '128GB',
    receivingPrice: 80,
    paymentMethod: ReceivingPaymentMethod.cash,
    supplierName: 'Supplier',
    supplierPhone: '000',
  );
}

void main() {
  late CallLog log;
  late FakeOrderRepository orders;
  late FakeInventoryDeviceRepository inventory;
  late FakeFinancialRepository financial;
  late CreateOrder createOrder;

  setUp(() {
    log = CallLog();
    orders = FakeOrderRepository(log);
    inventory = FakeInventoryDeviceRepository(log, [device('device-1'), device('device-2')]);
    financial = FakeFinancialRepository(log);
    createOrder = CreateOrder(orders, inventory, financial);
  });

  group('validation', () {
    test('rejects an order without items and touches nothing', () async {
      await expectLater(createOrder(order([])), throwsA(isA<OrderValidationException>()));
      expect(log.calls, isEmpty);
    });

    test('rejects a zero quantity', () async {
      await expectLater(createOrder(order([item(quantity: 0)])), throwsA(isA<OrderValidationException>()));
      expect(log.calls, isEmpty);
    });

    test('rejects a negative unit price', () async {
      await expectLater(createOrder(order([item(unitPrice: -1)])), throwsA(isA<OrderValidationException>()));
      expect(log.calls, isEmpty);
    });

    test('rejects a negative tax percentage', () async {
      await expectLater(createOrder(order([item(taxPercent: -14)])), throwsA(isA<OrderValidationException>()));
      expect(log.calls, isEmpty);
    });

    test('rejects a non-finite line total', () async {
      await expectLater(
        createOrder(order([item(lineTotal: double.nan)])),
        throwsA(isA<OrderValidationException>()),
      );
      expect(log.calls, isEmpty);
    });
  });

  group('totals', () {
    test('are recalculated from the items instead of trusting the caller', () async {
      await createOrder(order(
        [item(quantity: 2, unitPrice: 100, taxPercent: 14), item(productId: 'device-2', unitPrice: 50, taxPercent: 0)],
        subtotal: 1,
        taxAmount: 1,
        total: 1,
      ));

      final saved = orders.saved.single;
      expect(saved.subtotal, closeTo(250, 1e-9));
      expect(saved.taxAmount, closeTo(28, 1e-9));
      expect(saved.total, closeTo(278, 1e-9));
    });
  });

  group('side effects', () {
    test('the order is persisted before inventory and financials change', () async {
      await createOrder(order([item()]));

      expect(log.calls.first, 'order.create');
      expect(log.calls, containsAllInOrder(['order.create', 'device.update:device-1', 'financial.addToCash', 'financial.recordSale']));
    });

    test('a failed save leaves inventory and financials untouched', () async {
      orders.createError = StateError('offline');

      await expectLater(createOrder(order([item()])), throwsA(isA<StateError>()));

      expect(log.calls, ['order.create']);
      expect(inventory.devices['device-1']!.isSold, isFalse);
      expect(financial.cash, 0);
      expect(financial.sales, 0);
    });

    test('sold devices are marked with the selling price', () async {
      await createOrder(order([item(unitPrice: 120)]));

      final sold = inventory.devices['device-1']!;
      expect(sold.isSold, isTrue);
      expect(sold.sellingPrice, 120);
      expect(inventory.devices['device-2']!.isSold, isFalse);
    });

    test('cash, bank transfer and e-wallet orders go to cash', () async {
      for (final type in [OrderType.cash, OrderType.bankTransfer, OrderType.eWallet]) {
        await createOrder(order([item(taxPercent: 0)], type: type));
      }
      expect(financial.cash, 300);
      expect(financial.credit, 0);
    });

    test('credit orders go to credit and are still recorded as sales', () async {
      await createOrder(order([item(unitPrice: 200, taxPercent: 10)], type: OrderType.credit));

      expect(financial.credit, closeTo(220, 1e-9));
      expect(financial.cash, 0);
      expect(financial.sales, closeTo(220, 1e-9));
      expect(financial.taxes, closeTo(20, 1e-9));
    });

    test('a financial failure after a successful save does not fail the sale', () async {
      financial.cashError = StateError('summary unavailable');

      await createOrder(order([item()]));

      expect(orders.saved, hasLength(1));
      expect(financial.sales, greaterThan(0));
    });
  });
}
