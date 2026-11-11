import '../../core/constants/app_constants.dart';
import '../../core/utils/password_hash.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/employee_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._employeeRepository);

  final EmployeeRepository _employeeRepository;

  @override
  Future<UserEntity> login(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();
    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw AuthException('Email and password are required.');
    }

    final employee = await _employeeRepository.getByEmail(trimmedEmail);
    if (employee == null) {
      throw AuthException('Invalid email or password.');
    }
    if (!employee.isActive) {
      throw AuthException('Account is disabled. Contact administrator.');
    }
    if (!PasswordHash.verify(trimmedPassword, employee.passwordHash)) {
      throw AuthException('Invalid email or password.');
    }

    // Update last login timestamp (fire-and-forget)
    _employeeRepository.updateLastLoginAt(employee.id, DateTime.now());

    await _persistSession(employee.id);
    return _employeeToUser(employee);
  }

  @override
  Future<void> logout() async {
    await _clearSession();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final id = LocalStorage.authBox.get(AppConstants.keySessionUid) as String?;
    if (id == null || id.isEmpty) return null;
    final user = await getUserProfile(id);
    if (user == null || !user.isActive) {
      await _clearSession();
      return null;
    }
    return user;
  }

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    final employee = await _employeeRepository.getById(uid);
    if (employee == null) return null;
    if (!employee.isActive) return null;
    return _employeeToUser(employee);
  }

  /// Maps [EmployeeEntity] to [UserEntity] with role conversion.
  static UserEntity _employeeToUser(EmployeeEntity e) {
    return UserEntity(
      uid: e.id,
      name: e.name,
      email: e.email,
      role: _mapRole(e.role),
      isActive: e.isActive,
      createdAt: e.createdAt ?? DateTime.now(),
    );
  }

  /// Maps [EmployeeRole] → [UserRole] for RBAC.
  static UserRole _mapRole(EmployeeRole role) {
    return switch (role) {
      EmployeeRole.admin => UserRole.admin,
      EmployeeRole.manager => UserRole.admin,
      EmployeeRole.cashier => UserRole.cashier,
      EmployeeRole.inventoryStaff => UserRole.inventory,
      EmployeeRole.accountant => UserRole.finance,
    };
  }

  Future<void> _persistSession(String id) async {
    await LocalStorage.authBox.put(AppConstants.keySessionUid, id);
  }

  Future<void> _clearSession() async {
    await LocalStorage.authBox.delete(AppConstants.keySessionUid);
  }
}
