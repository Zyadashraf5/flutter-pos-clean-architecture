import 'package:equatable/equatable.dart';

/// Role for Firebase Auth + Firestore users collection (RBAC).
enum UserRole {
  admin,
  cashier,
  inventory,
  finance,
}

extension UserRoleX on UserRole {
  String get value => switch (this) {
        UserRole.admin => 'admin',
        UserRole.cashier => 'cashier',
        UserRole.inventory => 'inventory',
        UserRole.finance => 'finance',
      };
  String get displayName => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.cashier => 'Cashier',
        UserRole.inventory => 'Inventory',
        UserRole.finance => 'Finance',
      };
}

/// User profile from Firestore users/{uid}. Synced with Firebase Auth.
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  @override
  List<Object?> get props => [uid, name, email, role, isActive, createdAt];
}
