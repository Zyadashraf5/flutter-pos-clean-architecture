import '../../../core/utils/password_hash.dart';
import '../../entities/employee_entity.dart';
import '../../repositories/employee_repository.dart';

class CreateEmployee {
  CreateEmployee(this._repository);

  final EmployeeRepository _repository;

  Future<void> call({
    required String id,
    required String name,
    required String email,
    required String plainPassword,
    required EmployeeRole role,
    bool isActive = true,
  }) async {
    final hash = PasswordHash.hash(plainPassword);
    final entity = EmployeeEntity(
      id: id,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: hash,
      role: role,
      isActive: isActive,
      createdAt: DateTime.now(),
    );
    await _repository.create(entity);
  }
}
