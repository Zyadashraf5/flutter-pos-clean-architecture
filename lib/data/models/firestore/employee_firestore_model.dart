import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/employee_entity.dart';

class EmployeeFirestoreModel {
  const EmployeeFirestoreModel({
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
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'role': role,
        'isActive': isActive,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
        if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
      };

  factory EmployeeFirestoreModel.fromFirestore(String id, Map<String, dynamic> data) {
    final roleStr = data['role'] as String? ?? 'cashier';
    return EmployeeFirestoreModel(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      passwordHash: data['passwordHash'] as String? ?? '',
      role: roleStr,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  EmployeeEntity toEntity() {
    return EmployeeEntity(
      id: id,
      name: name,
      email: email,
      passwordHash: passwordHash,
      role: _roleFromString(role),
      isActive: isActive,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  static EmployeeRole _roleFromString(String s) {
    return switch (s) {
      'admin' => EmployeeRole.admin,
      'manager' => EmployeeRole.manager,
      'cashier' => EmployeeRole.cashier,
      'inventory_staff' => EmployeeRole.inventoryStaff,
      'accountant' => EmployeeRole.accountant,
      _ => EmployeeRole.cashier,
    };
  }
}
