import 'package:cashiere_system/core/utils/password_hash.dart';
import 'package:cashiere_system/domain/auth/permission.dart';
import 'package:cashiere_system/domain/auth/role_permissions.dart';
import 'package:cashiere_system/domain/entities/employee_entity.dart';
import 'package:cashiere_system/domain/entities/user_entity.dart';
import 'package:cashiere_system/domain/usecases/auth/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  group('PasswordHash', () {
    test('verifies the original password and rejects others', () {
      final hash = PasswordHash.hash('correct horse');
      expect(hash, isNot(contains('correct horse')));
      expect(PasswordHash.verify('correct horse', hash), isTrue);
      expect(PasswordHash.verify('wrong', hash), isFalse);
    });
  });

  group('LoginUseCase', () {
    late String hash;
    late FakeEmployeeRepository employees;
    late LoginUseCase login;

    EmployeeEntity employee({bool isActive = true}) => EmployeeEntity(
          id: 'emp-1',
          name: 'Cashier One',
          email: 'cashier@example.com',
          passwordHash: hash,
          role: EmployeeRole.cashier,
          isActive: isActive,
        );

    setUpAll(() => hash = PasswordHash.hash('s3cret-pass'));

    setUp(() {
      employees = FakeEmployeeRepository([employee()]);
      login = LoginUseCase(employees);
    });

    test('normalises the email before looking the employee up', () async {
      final result = await login('  Cashier@Example.COM ', 's3cret-pass');
      expect(result.id, 'emp-1');
      expect(employees.emailLookups.single, 'cashier@example.com');
    });

    test('rejects a wrong password with a generic message', () async {
      await expectLater(
        login('cashier@example.com', 'nope'),
        throwsA(isA<LoginException>().having((e) => e.message, 'message', 'Invalid email or password')),
      );
    });

    test('uses the same message for an unknown email', () async {
      await expectLater(
        login('ghost@example.com', 's3cret-pass'),
        throwsA(isA<LoginException>().having((e) => e.message, 'message', 'Invalid email or password')),
      );
    });

    test('blocks disabled accounts', () async {
      employees = FakeEmployeeRepository([employee(isActive: false)]);
      login = LoginUseCase(employees);
      await expectLater(login('cashier@example.com', 's3cret-pass'), throwsA(isA<LoginException>()));
    });

    test('requires both fields', () async {
      await expectLater(login('', 'x'), throwsA(isA<LoginException>()));
      await expectLater(login('cashier@example.com', ''), throwsA(isA<LoginException>()));
      expect(employees.emailLookups, isEmpty);
    });
  });

  group('PermissionService (employee roles)', () {
    test('admin has every permission', () {
      for (final p in Permission.values) {
        expect(PermissionService.hasPermission(EmployeeRole.admin, p), isTrue, reason: '$p');
      }
    });

    test('a cashier can sell but cannot see financials or manage staff', () {
      expect(PermissionService.hasPermission(EmployeeRole.cashier, Permission.createOrder), isTrue);
      expect(PermissionService.hasPermission(EmployeeRole.cashier, Permission.viewProducts), isTrue);
      expect(PermissionService.hasPermission(EmployeeRole.cashier, Permission.viewFinancial), isFalse);
      expect(PermissionService.hasPermission(EmployeeRole.cashier, Permission.manageEmployees), isFalse);
      expect(PermissionService.hasPermission(EmployeeRole.cashier, Permission.deleteOrder), isFalse);
    });

    test('only admins can delete orders or suppliers', () {
      for (final role in EmployeeRole.values.where((r) => r != EmployeeRole.admin)) {
        expect(PermissionService.hasPermission(role, Permission.deleteOrder), isFalse, reason: '$role');
        expect(PermissionService.hasPermission(role, Permission.deleteSupplier), isFalse, reason: '$role');
      }
    });

    test('route guard follows the permission matrix', () {
      expect(PermissionService.canAccessRoute(EmployeeRole.cashier, '/orders'), isTrue);
      expect(PermissionService.canAccessRoute(EmployeeRole.cashier, '/financial'), isFalse);
      expect(PermissionService.canAccessRoute(EmployeeRole.accountant, '/financial'), isTrue);
      expect(PermissionService.canAccessRoute(EmployeeRole.inventoryStaff, '/employees'), isFalse);
    });
  });

  group('RolePermissions (session roles)', () {
    test('finance users reach financials but not orders', () {
      expect(RolePermissions.canAccessRoute(UserRole.finance, '/financial'), isTrue);
      expect(RolePermissions.canAccessRoute(UserRole.finance, '/orders'), isFalse);
    });

    test('inventory users manage stock but not admin screens', () {
      expect(RolePermissions.canAccessRoute(UserRole.inventory, '/inventory'), isTrue);
      expect(RolePermissions.canAccessRoute(UserRole.inventory, '/admin'), isFalse);
    });

    test('admins reach every route', () {
      for (final route in ['/', '/orders', '/financial', '/admin', '/employees']) {
        expect(RolePermissions.canAccessRoute(UserRole.admin, route), isTrue, reason: route);
      }
    });
  });
}
