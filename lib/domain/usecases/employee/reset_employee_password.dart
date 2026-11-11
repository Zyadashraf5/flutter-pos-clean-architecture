import '../../../core/utils/password_hash.dart';
import '../../entities/employee_entity.dart';
import '../../repositories/employee_repository.dart';

class ResetEmployeePassword {
  ResetEmployeePassword(this._repository);

  final EmployeeRepository _repository;

  Future<void> call(String employeeId, String newPlainPassword) async {
    final existing = await _repository.getById(employeeId);
    if (existing == null) return;
    final hash = PasswordHash.hash(newPlainPassword);
    final entity = EmployeeEntity(
      id: existing.id,
      name: existing.name,
      email: existing.email,
      passwordHash: hash,
      role: existing.role,
      isActive: existing.isActive,
      createdAt: existing.createdAt,
      lastLoginAt: existing.lastLoginAt,
    );
    await _repository.update(entity);
  }
}
