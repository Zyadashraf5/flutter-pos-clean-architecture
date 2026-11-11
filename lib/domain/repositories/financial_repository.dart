import '../entities/financial_entity.dart';

abstract class FinancialRepository {
  Future<FinancialSummaryEntity> getSummary();
  Stream<FinancialSummaryEntity> watchSummary();
  Future<double> getTotalCash();
  Future<double> getTotalCredit();
  Future<void> setTotalCash(double value);
  Future<void> setTotalCredit(double value);
  Future<void> addToCash(double amount);
  Future<void> addToCredit(double amount);

  /// Positive [amount] increases debt, negative decreases (e.g. payment).
  Future<void> addToSupplierDebt(double amount);

  /// Record a sale: increments totalSales and taxesCollected in financial summary.
  Future<void> recordSale(double saleTotal, double taxAmount);
}
