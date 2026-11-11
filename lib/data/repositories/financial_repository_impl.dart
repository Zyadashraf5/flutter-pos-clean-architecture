import '../../domain/entities/financial_entity.dart';
import '../../domain/repositories/financial_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/firebase/firebase_financial_summary_datasource.dart';
import '../datasources/local/financial_local_datasource.dart';
import '../../core/utils/app_logger.dart';

class FinancialRepositoryImpl implements FinancialRepository {
  FinancialRepositoryImpl(
    this._datasource,
    this._orderRepository,
    this._productRepository, {
    FirebaseFinancialSummaryDataSource? firestoreSummary,
  }) : _firestoreSummary = firestoreSummary;

  final FinancialLocalDatasource _datasource;
  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;
  final FirebaseFinancialSummaryDataSource? _firestoreSummary;

  @override
  Future<FinancialSummaryEntity> getSummary() async {
    if (_firestoreSummary != null) {
      try {
        final fs = await _firestoreSummary.get();
        if (fs != null) {
          final orders = await _orderRepository.getAll();
          final products = await _productRepository.getAll();
          double inventoryValue = 0;
          for (final p in products) {
            inventoryValue += p.purchasePrice * p.quantity;
          }
          AppLogger.repository('Financial', 'getSummary() from Firestore');
          return FinancialSummaryEntity(
            totalCash: fs.totalCash,
            totalCredit: fs.totalCredit,
            totalSales: fs.totalSales,
            taxesCollected: fs.totalTaxesCollected,
            inventoryValue: inventoryValue,
            totalOrders: orders.length,
            supplierDebt: fs.supplierDebt,
            updatedAt: fs.updatedAt,
          );
        }
      } catch (e) {
        AppLogger.repository(
          'Financial',
          'getSummary() Firestore failed, fallback to local',
          e,
        );
      }
    }
    final totalCash = await _datasource.getTotalCash();
    final totalCredit = await _datasource.getTotalCredit();
    final orders = await _orderRepository.getAll();
    double totalSales = 0;
    double taxesCollected = 0;
    for (final o in orders) {
      totalSales += o.total;
      taxesCollected += o.taxAmount;
    }
    final products = await _productRepository.getAll();
    double inventoryValue = 0;
    for (final p in products) {
      inventoryValue += p.purchasePrice * p.quantity;
    }
    return FinancialSummaryEntity(
      totalCash: totalCash,
      totalCredit: totalCredit,
      totalSales: totalSales,
      taxesCollected: taxesCollected,
      inventoryValue: inventoryValue,
      totalOrders: orders.length,
      supplierDebt: 0,
    );
  }

  @override
  Stream<FinancialSummaryEntity> watchSummary() {
    if (_firestoreSummary == null) {
      return Stream.fromFuture(getSummary());
    }
    return _firestoreSummary.watch().asyncMap((fs) async {
      if (fs == null) return getSummary();
      final orders = await _orderRepository.getAll();
      final products = await _productRepository.getAll();
      double inventoryValue = 0;
      for (final p in products) {
        inventoryValue += p.purchasePrice * p.quantity;
      }
      return FinancialSummaryEntity(
        totalCash: fs.totalCash,
        totalCredit: fs.totalCredit,
        totalSales: fs.totalSales,
        taxesCollected: fs.totalTaxesCollected,
        inventoryValue: inventoryValue,
        totalOrders: orders.length,
        supplierDebt: fs.supplierDebt,
        updatedAt: fs.updatedAt,
      );
    });
  }

  @override
  Future<void> addToSupplierDebt(double amount) async {
    if (amount == 0) return;
    final fs = _firestoreSummary;
    if (fs != null) {
      try {
        await fs.updateInTransaction(addToSupplierDebt: amount);
      } catch (e) {
        AppLogger.repository(
          'Financial',
          'addToSupplierDebt Firestore failed',
          e,
        );
      }
    }
  }

  @override
  Future<double> getTotalCash() => _datasource.getTotalCash();

  @override
  Future<double> getTotalCredit() => _datasource.getTotalCredit();

  @override
  Future<void> setTotalCash(double value) => _datasource.setTotalCash(value);

  @override
  Future<void> setTotalCredit(double value) =>
      _datasource.setTotalCredit(value);

  @override
  Future<void> addToCash(double amount) async {
    await _datasource.addToCash(amount);
    final fs = _firestoreSummary;
    if (fs != null && amount != 0) {
      try {
        await fs.updateInTransaction(addToCash: amount);
      } catch (e) {
        AppLogger.repository(
          'Financial',
          'addToCash Firestore transaction failed',
          e,
        );
      }
    }
  }

  @override
  Future<void> addToCredit(double amount) async {
    await _datasource.addToCredit(amount);
    final fs = _firestoreSummary;
    if (fs != null && amount != 0) {
      try {
        await fs.updateInTransaction(addToCredit: amount);
      } catch (e) {
        AppLogger.repository(
          'Financial',
          'addToCredit Firestore transaction failed',
          e,
        );
      }
    }
  }

  @override
  Future<void> recordSale(double saleTotal, double taxAmount) async {
    if (saleTotal == 0 && taxAmount == 0) return;
    final fs = _firestoreSummary;
    if (fs != null) {
      try {
        await fs.updateInTransaction(
          addToSales: saleTotal,
          addToTaxesCollected: taxAmount,
        );
      } catch (e) {
        AppLogger.repository('Financial', 'recordSale Firestore failed', e);
      }
    }
  }
}
