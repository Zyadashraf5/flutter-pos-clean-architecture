import 'package:cashiere_system/core/routes/app_routes.dart';
import 'package:cashiere_system/domain/auth/role_permissions.dart';
import 'package:cashiere_system/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Access matrix for known screens plus fail-closed checks for unmapped routes.
const screens = <String>{
  AppRoutes.dashboard,
  AppRoutes.categories,
  AppRoutes.categoryForm,
  AppRoutes.products,
  AppRoutes.productForm,
  AppRoutes.orders,
  AppRoutes.orderCreate,
  AppRoutes.inventory,
  AppRoutes.inventoryDeviceForm,
  AppRoutes.financial,
  AppRoutes.suppliers,
  AppRoutes.supplierForm,
  AppRoutes.purchaseCreate,
  AppRoutes.qrScanner,
  AppRoutes.admin,
  AppRoutes.employees,
};

void expectAccess(UserRole role, Set<String> allowed) {
  for (final route in screens) {
    expect(
      RolePermissions.canAccessRoute(role, route),
      allowed.contains(route),
      reason: '${role.name} -> $route',
    );
  }
}

void main() {
  test('unmapped routes are denied for every role, including admins', () {
    for (final role in UserRole.values) {
      expect(RolePermissions.canAccessRoute(role, '/unmapped-screen'), isFalse);
      expect(RolePermissions.canAccessRoute(role, ''), isFalse);
    }
  });

  test('finance users only reach the dashboard and financials', () {
    expectAccess(UserRole.finance, {AppRoutes.dashboard, AppRoutes.financial});
  });

  test('cashiers only reach the dashboard and orders', () {
    expectAccess(UserRole.cashier, {AppRoutes.dashboard, AppRoutes.orders, AppRoutes.orderCreate});
  });

  test('inventory staff reach products, stock, suppliers and purchases', () {
    expectAccess(UserRole.inventory, {
      AppRoutes.dashboard,
      AppRoutes.categories,
      AppRoutes.categoryForm,
      AppRoutes.products,
      AppRoutes.productForm,
      AppRoutes.inventory,
      AppRoutes.inventoryDeviceForm,
      AppRoutes.suppliers,
      AppRoutes.supplierForm,
      AppRoutes.purchaseCreate,
      AppRoutes.qrScanner,
    });
  });

  test('admins reach every screen', () {
    expectAccess(UserRole.admin, screens);
  });
}
