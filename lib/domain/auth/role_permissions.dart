import '../entities/user_entity.dart';

/// String-based permissions for RBAC. Used by AuthController.hasPermission(String).
class RolePermissions {
  RolePermissions._();

  static const String fullAccess = 'full';
  static const String dashboard = 'dashboard';
  static const String orders = 'orders';
  static const String products = 'products';
  static const String inventory = 'inventory';
  static const String financial = 'financial';
  static const String admin = 'admin';

  static final Map<UserRole, Set<String>> _rolePermissions = {
    UserRole.admin: {fullAccess, dashboard, orders, products, inventory, financial, admin},
    UserRole.cashier: {dashboard, orders},
    UserRole.inventory: {dashboard, products, inventory},
    UserRole.finance: {dashboard, financial},
  };

  static bool hasPermission(UserRole role, String permission) {
    final perms = _rolePermissions[role];
    if (perms == null) return false;
    if (perms.contains(fullAccess) || perms.contains(admin)) return true;
    return perms.contains(permission);
  }

  static bool canAccessRoute(UserRole role, String route) {
    if (hasPermission(role, fullAccess)) return true;
    final routeToPermission = <String, String>{
      '/': dashboard,
      '/dashboard': dashboard,
      '/orders': orders,
      '/orders/create': orders,
      '/products': products,
      '/products/form': products,
      '/categories': products,
      '/categories/form': products,
      '/inventory': inventory,
      '/inventory/device-form': inventory,
      '/suppliers': inventory,
      '/suppliers/form': inventory,
      '/purchases/create': inventory,
      '/qr-scanner': products,
      '/financial': financial,
      '/admin': admin,
      '/employees': admin,
    };
    final perm = routeToPermission[route];
    if (perm == null) return true;
    return hasPermission(role, perm);
  }
}
