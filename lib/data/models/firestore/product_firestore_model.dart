import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFirestoreModel {
  const ProductFirestoreModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    required this.barcode,
    required this.taxPercentage,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUid,
    this.updatedByUid,
  });

  final String id;
  final String name;
  final String categoryId;
  final double purchasePrice;
  final double sellingPrice;
  final int quantity;
  final String barcode;
  final double taxPercentage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdByUid;
  final String? updatedByUid;

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'purchasePrice': purchasePrice,
    'sellingPrice': sellingPrice,
    'quantity': quantity,
    'barcode': barcode,
    'taxPercentage': taxPercentage,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    if (createdByUid != null) 'createdByUid': createdByUid,
    if (updatedByUid != null) 'updatedByUid': updatedByUid,
  };

  factory ProductFirestoreModel.fromFirestore(Map<String, dynamic> data) {

    return ProductFirestoreModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      purchasePrice: (data['purchasePrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (data['sellingPrice'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      barcode: data['barcode'] as String? ?? '',
      taxPercentage: (data['taxPercentage'] as num?)?.toDouble() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdByUid: data['createdByUid'] as String?,
      updatedByUid: data['updatedByUid'] as String?,
    );
  }
}
