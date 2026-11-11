import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/user_entity.dart';

class UserFirestoreModel {
  const UserFirestoreModel({
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
  final String role;
  final bool isActive;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'role': role,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory UserFirestoreModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return UserFirestoreModel(
      uid: docId,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'cashier',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  UserEntity toEntity() {
    final roleEnum = UserRole.values.firstWhere(
      (r) => r.value == role,
      orElse: () => UserRole.cashier,
    );
    return UserEntity(
      uid: uid,
      name: name,
      email: email,
      role: roleEnum,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  static UserRole roleFromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.cashier,
    );
  }
}
