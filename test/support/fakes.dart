import 'package:cashiere_system/domain/entities/employee_entity.dart';
import 'package:cashiere_system/domain/entities/financial_entity.dart';
import 'package:cashiere_system/domain/entities/inventory_device_entity.dart';
import 'package:cashiere_system/domain/entities/order_entity.dart';
import 'package:cashiere_system/domain/entities/product_entity.dart';
import 'package:cashiere_system/domain/entities/purchase_entity.dart';
import 'package:cashiere_system/domain/entities/supplier_entity.dart';
import 'package:cashiere_system/domain/repositories/employee_repository.dart';
import 'package:cashiere_system/domain/repositories/financial_repository.dart';
import 'package:cashiere_system/domain/repositories/inventory_device_repository.dart';
import 'package:cashiere_system/domain/repositories/order_repository.dart';
import 'package:cashiere_system/domain/repositories/product_repository.dart';
import 'package:cashiere_system/domain/repositories/purchase_repository.dart';
import 'package:cashiere_system/domain/repositories/supplier_repository.dart';

/// In-memory fakes for the domain repositories.
///
/// Every fake writes to a shared [CallLog] so tests can assert the order in
/// which a use case touches its collaborators.
class CallLog {
  final List<String> calls = [];
  void add(String call) => calls.add(call);
}

class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository(this.log);

  final CallLog log;
  final List<OrderEntity> saved = [];
  Object? createError;

  @override
  Future<void> create(OrderEntity order) async {
    log.add('order.create');
    if (createError != null) throw createError!;
    saved.add(order);
  }

  @override
  Future<void> delete(String id) async => saved.removeWhere((o) => o.id == id);

  @override
  Future<List<OrderEntity>> getAll() async => List.of(saved);

  @override
  Future<OrderEntity?> getById(String id) async {
    for (final o in saved) {
      if (o.id == id) return o;
    }
    return null;
  }
}

class FakeInventoryDeviceRepository implements InventoryDeviceRepository {
  FakeInventoryDeviceRepository(this.log, [List<InventoryDeviceEntity> seed = const []]) {
    for (final d in seed) {
      devices[d.id] = d;
    }
  }

  final CallLog log;
  final Map<String, InventoryDeviceEntity> devices = {};

  @override
  Future<InventoryDeviceEntity?> getById(String id) async => devices[id];

  @override
  Future<void> update(InventoryDeviceEntity entity) async {
    log.add('device.update:${entity.id}');
    devices[entity.id] = entity;
  }

  @override
  Future<void> create(InventoryDeviceEntity entity) async => devices[entity.id] = entity;

  @override
  Future<void> delete(String id) async => devices.remove(id);

  @override
  Future<List<InventoryDeviceEntity>> getAll() async => devices.values.toList();

  @override
  Future<InventoryDeviceEntity?> getByBarcode(String barcode) async {
    for (final d in devices.values) {
      if (d.barcode == barcode) return d;
    }
    return null;
  }
}

class FakeFinancialRepository implements FinancialRepository {
  FakeFinancialRepository(this.log);

  final CallLog log;
  double cash = 0;
  double credit = 0;
  double sales = 0;
  double taxes = 0;
  double supplierDebt = 0;
  Object? cashError;

  @override
  Future<void> addToCash(double amount) async {
    log.add('financial.addToCash');
    if (cashError != null) throw cashError!;
    cash += amount;
  }

  @override
  Future<void> addToCredit(double amount) async {
    log.add('financial.addToCredit');
    credit += amount;
  }

  @override
  Future<void> recordSale(double saleTotal, double taxAmount) async {
    log.add('financial.recordSale');
    sales += saleTotal;
    taxes += taxAmount;
  }

  @override
  Future<void> addToSupplierDebt(double amount) async {
    log.add('financial.addToSupplierDebt');
    supplierDebt += amount;
  }

  @override
  Future<FinancialSummaryEntity> getSummary() async => FinancialSummaryEntity(
        totalCash: cash,
        totalCredit: credit,
        totalSales: sales,
        taxesCollected: taxes,
        inventoryValue: 0,
        totalOrders: 0,
        supplierDebt: supplierDebt,
      );

  @override
  Stream<FinancialSummaryEntity> watchSummary() => Stream.fromFuture(getSummary());

  @override
  Future<double> getTotalCash() async => cash;

  @override
  Future<double> getTotalCredit() async => credit;

  @override
  Future<void> setTotalCash(double value) async => cash = value;

  @override
  Future<void> setTotalCredit(double value) async => credit = value;
}

class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository(this.log);

  final CallLog log;
  final List<PurchaseEntity> saved = [];
  Object? createError;

  @override
  Future<void> create(PurchaseEntity purchase) async {
    log.add('purchase.create');
    if (createError != null) throw createError!;
    saved.add(purchase);
  }

  @override
  Future<List<PurchaseEntity>> getAll() async => List.of(saved);

  @override
  Future<List<PurchaseEntity>> getByDateRange(DateTime start, DateTime end) async => saved
      .where((p) => !p.createdAt.isBefore(start) && !p.createdAt.isAfter(end))
      .toList();
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.log);

  final CallLog log;
  final Map<String, int> stockAdded = {};
  final Map<String, double?> lastPurchasePrice = {};

  @override
  Future<void> increaseStock(String productId, int quantity, {double? purchasePrice}) async {
    log.add('product.increaseStock:$productId');
    stockAdded[productId] = (stockAdded[productId] ?? 0) + quantity;
    lastPurchasePrice[productId] = purchasePrice;
  }

  @override
  Future<void> decreaseStock(String productId, int quantity) async {}

  @override
  Future<void> create(ProductEntity entity) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<ProductEntity>> getAll() async => const [];

  @override
  Future<ProductEntity?> getByBarcode(String barcode) async => null;

  @override
  Future<List<ProductEntity>> getByCategoryId(String categoryId) async => const [];

  @override
  Future<ProductEntity?> getById(String id) async => null;

  @override
  Future<void> update(ProductEntity entity) async {}
}

class FakeSupplierRepository implements SupplierRepository {
  FakeSupplierRepository(this.log);

  final CallLog log;
  final Map<String, double> debt = {};
  final Map<String, double> paid = {};

  @override
  Future<void> addDebt(String supplierId, double amount) async {
    log.add('supplier.addDebt');
    debt[supplierId] = (debt[supplierId] ?? 0) + amount;
  }

  @override
  Future<void> recordPayment(String supplierId, double amount) async {
    log.add('supplier.recordPayment');
    paid[supplierId] = (paid[supplierId] ?? 0) + amount;
  }

  @override
  Future<void> create(SupplierEntity entity) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<SupplierEntity>> getAll() async => const [];

  @override
  Future<SupplierEntity?> getById(String id) async => null;

  @override
  Future<void> update(SupplierEntity entity) async {}
}

class FakeEmployeeRepository implements EmployeeRepository {
  FakeEmployeeRepository([List<EmployeeEntity> seed = const []]) {
    for (final e in seed) {
      byId[e.id] = e;
    }
  }

  final Map<String, EmployeeEntity> byId = {};
  final List<String> emailLookups = [];

  @override
  Future<EmployeeEntity?> getByEmail(String email) async {
    emailLookups.add(email);
    for (final e in byId.values) {
      if (e.email == email) return e;
    }
    return null;
  }

  @override
  Future<EmployeeEntity?> getById(String id) async => byId[id];

  @override
  Future<List<EmployeeEntity>> getAll() async => byId.values.toList();

  @override
  Future<void> create(EmployeeEntity entity) async => byId[entity.id] = entity;

  @override
  Future<void> update(EmployeeEntity entity) async => byId[entity.id] = entity;

  @override
  Future<void> updateLastLoginAt(String id, DateTime at) async {}
}
