import '../entities/employee_entity.dart';

abstract class EmployeeRepository {
  Future<EmployeeEntity?> getByEmail(String email);
  Future<EmployeeEntity?> getById(String id);
  Future<List<EmployeeEntity>> getAll();
  Future<void> create(EmployeeEntity entity);
  Future<void> update(EmployeeEntity entity);
  Future<void> updateLastLoginAt(String id, DateTime at);
}
