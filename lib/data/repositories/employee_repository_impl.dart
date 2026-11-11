import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/firebase/firebase_employee_datasource.dart';
import '../models/firestore/employee_firestore_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl(this._datasource);

  final FirebaseEmployeeDataSource _datasource;

  @override
  Future<EmployeeEntity?> getByEmail(String email) async {
    final model = await _datasource.getByEmail(email);
    return model?.toEntity();
  }

  @override
  Future<EmployeeEntity?> getById(String id) async {
    final model = await _datasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<EmployeeEntity>> getAll() async {
    final list = await _datasource.getAll();
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> create(EmployeeEntity entity) async {
    final model = EmployeeFirestoreModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      passwordHash: entity.passwordHash,
      role: entity.role.value,
      isActive: entity.isActive,
      createdAt: entity.createdAt ?? DateTime.now(),
      lastLoginAt: entity.lastLoginAt,
    );
    await _datasource.create(model);
  }

  @override
  Future<void> update(EmployeeEntity entity) async {
    final model = EmployeeFirestoreModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      passwordHash: entity.passwordHash,
      role: entity.role.value,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
    await _datasource.update(model);
  }

  @override
  Future<void> updateLastLoginAt(String id, DateTime at) async {
    await _datasource.updateLastLoginAt(id, at);
  }
}
