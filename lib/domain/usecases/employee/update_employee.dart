import '../../entities/employee_entity.dart';
import '../../repositories/employee_repository.dart';

class UpdateEmployee {
  UpdateEmployee(this._repository);

  final EmployeeRepository _repository;

  /// Updates name, email, role, isActive. Keeps existing passwordHash and timestamps.
  Future<void> call({
    required String id,
    String? name,
    String? email,
    EmployeeRole? role,
    bool? isActive,
  }) async {
    final existing = await _repository.getById(id);
    if (existing == null) return;
    final entity = EmployeeEntity(
      id: id,
      name: name ?? existing.name,
      email: (email ?? existing.email).trim().toLowerCase(),
      passwordHash: existing.passwordHash,
      role: role ?? existing.role,
      isActive: isActive ?? existing.isActive,
      createdAt: existing.createdAt,
      lastLoginAt: existing.lastLoginAt,
    );
    await _repository.update(entity);
  }
}
