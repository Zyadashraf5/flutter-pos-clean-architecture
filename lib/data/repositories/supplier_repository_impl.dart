import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/firebase/firebase_supplier_datasource.dart';
import '../models/firestore/supplier_firestore_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl(this._datasource);

  final FirebaseSupplierDataSource _datasource;

  @override
  Future<List<SupplierEntity>> getAll() async {
    final list = await _datasource.getAll();
    return list.map(_toEntity).toList();
  }

  @override
  Future<SupplierEntity?> getById(String id) async {
    final model = await _datasource.getById(id);
    return model != null ? _toEntity(model) : null;
  }

  @override
  Future<void> create(SupplierEntity entity) async {
    final model = SupplierFirestoreModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      totalDebt: entity.totalDebt,
      totalPaid: entity.totalPaid,
      createdAt: entity.createdAt ?? DateTime.now(),
      updatedAt: entity.updatedAt ?? DateTime.now(),
    );
    await _datasource.create(model);
  }

  @override
  Future<void> update(SupplierEntity entity) async {
    final model = SupplierFirestoreModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      totalDebt: entity.totalDebt,
      totalPaid: entity.totalPaid,
      createdAt: entity.createdAt,
      updatedAt: DateTime.now(),
    );
    await _datasource.update(model);
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
  }

  @override
  Future<void> addDebt(String supplierId, double amount) async {
    if (amount <= 0) return;
    await _datasource.updateDebt(supplierId, amount, 0);
  }

  @override
  Future<void> recordPayment(String supplierId, double amount) async {
    if (amount <= 0) return;
    await _datasource.updateDebt(supplierId, -amount, amount);
  }

  SupplierEntity _toEntity(SupplierFirestoreModel m) {
    return SupplierEntity(
      id: m.id,
      name: m.name,
      phone: m.phone,
      totalDebt: m.totalDebt,
      totalPaid: m.totalPaid,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );
  }
}
