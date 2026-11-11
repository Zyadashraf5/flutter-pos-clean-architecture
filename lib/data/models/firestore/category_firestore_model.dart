import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryFirestoreModel {
  const CategoryFirestoreModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'name': name,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'isActive': isActive,
      };

  factory CategoryFirestoreModel.fromFirestore(Map<String, dynamic> data) {
    return CategoryFirestoreModel(
      id: data['id'] as String,
      name: data['name'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}
