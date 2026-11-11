import '../entities/supplier_entity.dart';

abstract class SupplierRepository {
  Future<List<SupplierEntity>> getAll();
  Future<SupplierEntity?> getById(String id);
  Future<void> create(SupplierEntity entity);
  Future<void> update(SupplierEntity entity);
  Future<void> delete(String id);
  Future<void> addDebt(String supplierId, double amount);
  Future<void> recordPayment(String supplierId, double amount);
}
