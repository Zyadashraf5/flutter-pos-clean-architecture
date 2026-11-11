import 'package:equatable/equatable.dart';

enum EmployeeRole {
  admin,
  manager,
  cashier,
  inventoryStaff,
  accountant,
}

extension EmployeeRoleX on EmployeeRole {
  String get value => switch (this) {
        EmployeeRole.admin => 'admin',
        EmployeeRole.manager => 'manager',
        EmployeeRole.cashier => 'cashier',
        EmployeeRole.inventoryStaff => 'inventory_staff',
        EmployeeRole.accountant => 'accountant',
      };
  String get displayName => switch (this) {
        EmployeeRole.admin => 'Admin',
        EmployeeRole.manager => 'Manager',
        EmployeeRole.cashier => 'Cashier',
        EmployeeRole.inventoryStaff => 'Inventory Staff',
        EmployeeRole.accountant => 'Accountant',
      };
}

class EmployeeEntity extends Equatable {
  const EmployeeEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final EmployeeRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  @override
  List<Object?> get props => [id, name, email, role, isActive, createdAt, lastLoginAt];
}
