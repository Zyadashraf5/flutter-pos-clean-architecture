import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierFirestoreModel {
  const SupplierFirestoreModel({
    required this.id,
    required this.name,
    this.phone,
    this.totalDebt = 0,
    this.totalPaid = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? phone;
  final double totalDebt;
  final double totalPaid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toFirestore() => {
        'name': name,
        if (phone != null) 'phone': phone,
        'totalDebt': totalDebt,
        'totalPaid': totalPaid,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      };

  factory SupplierFirestoreModel.fromFirestore(String id, Map<String, dynamic> data) {
    return SupplierFirestoreModel(
      id: id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String?,
      totalDebt: (data['totalDebt'] as num?)?.toDouble() ?? 0,
      totalPaid: (data['totalPaid'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
