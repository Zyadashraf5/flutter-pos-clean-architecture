import '../../repositories/financial_repository.dart';
import '../../repositories/supplier_repository.dart';

/// Records a payment to a supplier: decreases supplier debt and financial summary supplier debt.
class RecordSupplierPayment {
  RecordSupplierPayment(this._supplierRepository, this._financialRepository);

  final SupplierRepository _supplierRepository;
  final FinancialRepository _financialRepository;

  Future<void> call(String supplierId, double amount) async {
    if (amount <= 0) return;
    await _supplierRepository.recordPayment(supplierId, amount);
    await _financialRepository.addToSupplierDebt(-amount);
  }
}
