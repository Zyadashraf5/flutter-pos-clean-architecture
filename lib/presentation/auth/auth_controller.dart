import 'package:get/get.dart';

import '../../domain/auth/permission.dart';
import '../../domain/auth/role_permissions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  final currentUser = Rxn<UserEntity>();
  final loading = false.obs;

  bool get isLoggedIn => currentUser.value != null;

  UserEntity? get user => currentUser.value;

  bool hasPermission(String permission) {
    final u = currentUser.value;
    if (u == null) return false;
    return RolePermissions.hasPermission(u.role, permission);
  }

  /// For backward compatibility with controllers that use Permission enum.
  bool hasPermissionEnum(Permission permission) {
    final u = currentUser.value;
    if (u == null) return false;
    return RolePermissions.hasPermission(u.role, _permissionToRole(permission));
  }

  static String _permissionToRole(Permission p) {
    switch (p) {
      case Permission.fullAccess:
        return RolePermissions.fullAccess;
      case Permission.viewFinancial:
        return RolePermissions.financial;
      case Permission.viewReports:
        return RolePermissions.dashboard;
      case Permission.manageProducts:
      case Permission.viewProducts:
        return RolePermissions.products;
      case Permission.manageOrders:
      case Permission.createOrder:
        return RolePermissions.orders;
      case Permission.updateStock:
        return RolePermissions.inventory;
      case Permission.manageEmployees:
        return RolePermissions.admin;
      case Permission.deleteOrder:
        return 'delete_orders';
      case Permission.deleteSupplier:
        return 'delete_suppliers';
    }
  }

  bool canAccessRoute(String route) {
    final u = currentUser.value;
    if (u == null) return false;
    return RolePermissions.canAccessRoute(u.role, route);
  }

  @override
  void onReady() {
    loadCurrentUser();
    super.onReady();
  }

  Future<void> loadCurrentUser() async {
    try {
      final u = await _authRepository.getCurrentUser();
      currentUser.value = u;
    } catch (_) {
      currentUser.value = null;
    }
  }

  Future<bool> login(String email, String password) async {
    loading.value = true;
    try {
      final u = await _authRepository.login(email, password);
      currentUser.value = u;
      return true;
    } on AuthException {
      rethrow;
    } catch (e) {
      rethrow;
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    currentUser.value = null;
  }
}
