import '../entities/employee_entity.dart';

/// Permissions for RBAC. Controllers must check these before executing.
enum Permission {
  // Full
  fullAccess,

  // Financial
  viewFinancial,
  viewReports,

  // Products
  manageProducts,
  viewProducts,

  // Orders
  manageOrders,
  createOrder,

  // Inventory / Stock
  updateStock,

  // Employees (admin only)
  manageEmployees,

  // Admin-only destructive actions
  deleteOrder,
  deleteSupplier,
}

/// Maps roles to allowed permissions. UI and controllers use this.
class PermissionService {
  PermissionService._();

  static final Map<EmployeeRole, Set<Permission>> _rolePermissions = {
    EmployeeRole.admin: {
      Permission.fullAccess,
      Permission.viewFinancial,
      Permission.viewReports,
      Permission.manageProducts,
      Permission.viewProducts,
      Permission.manageOrders,
      Permission.createOrder,
      Permission.updateStock,
      Permission.manageEmployees,
      Permission.deleteOrder,
      Permission.deleteSupplier,
    },
    EmployeeRole.manager: {
      Permission.viewFinancial,
      Permission.viewReports,
      Permission.manageProducts,
      Permission.viewProducts,
      Permission.manageOrders,
      Permission.createOrder,
      Permission.updateStock,
    },
    EmployeeRole.cashier: {
      Permission.viewProducts,
      Permission.createOrder,
    },
    EmployeeRole.inventoryStaff: {
      Permission.manageProducts,
      Permission.viewProducts,
      Permission.updateStock,
    },
    EmployeeRole.accountant: {
      Permission.viewFinancial,
      Permission.viewReports,
      Permission.viewProducts,
    },
  };

  static bool hasPermission(EmployeeRole role, Permission permission) {
    final perms = _rolePermissions[role];
    if (perms == null) return false;
    if (perms.contains(Permission.fullAccess)) return true;
    return perms.contains(permission);
  }

  static bool canAccessRoute(EmployeeRole role, String route) {
    if (role == EmployeeRole.admin) return true;
    final routeToPermission = <String, Permission>{
      '/financial': Permission.viewFinancial,
      '/dashboard': Permission.viewReports,
      '/categories': Permission.manageProducts,
      '/categories/form': Permission.manageProducts,
      '/products': Permission.viewProducts,
      '/products/form': Permission.manageProducts,
      '/orders': Permission.createOrder,
      '/orders/create': Permission.createOrder,
      '/inventory': Permission.updateStock,
      '/inventory/device-form': Permission.updateStock,
      '/suppliers': Permission.updateStock,
      '/suppliers/form': Permission.updateStock,
      '/purchases/create': Permission.updateStock,
      '/qr-scanner': Permission.viewProducts,
      '/admin': Permission.manageEmployees,
      '/employees': Permission.manageEmployees,
    };
    final perm = routeToPermission[route];
    if (perm == null) return true;
    return hasPermission(role, perm);
  }
}
