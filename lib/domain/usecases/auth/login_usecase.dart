import '../../../core/utils/password_hash.dart';
import '../../entities/employee_entity.dart';
import '../../repositories/employee_repository.dart';

class LoginUseCase {
  LoginUseCase(this._employeeRepository);

  final EmployeeRepository _employeeRepository;

  /// Returns [EmployeeEntity] on success. Throws [LoginException] on failure.
  Future<EmployeeEntity> call(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) throw LoginException('Email is required');
    if (password.isEmpty) throw LoginException('Password is required');

    final employee = await _employeeRepository.getByEmail(trimmedEmail);
    if (employee == null) throw LoginException('Invalid email or password');

    if (!employee.isActive) throw LoginException('Account is disabled');

    if (!PasswordHash.verify(password, employee.passwordHash)) {
      throw LoginException('Invalid email or password');
    }

    return employee;
  }
}

class LoginException implements Exception {
  LoginException(this.message);
  final String message;
  @override
  String toString() => message;
}
