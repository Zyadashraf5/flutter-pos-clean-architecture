import 'package:cloud_firestore/cloud_firestore.dart';

enum PurchaseTypeFirestore { cash, credit }

class PurchaseItemFirestoreModel {
  const PurchaseItemFirestoreModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double purchasePrice;

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'purchasePrice': purchasePrice,
      };

  factory PurchaseItemFirestoreModel.fromFirestore(Map<String, dynamic> data) {
    return PurchaseItemFirestoreModel(
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 0,
      purchasePrice: (data['purchasePrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PurchaseFirestoreModel {
  const PurchaseFirestoreModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseType,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.createdAt,
  });

  final String id;
  final String supplierId;
  final String supplierName;
  final PurchaseTypeFirestore purchaseType;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() => {
        'supplierId': supplierId,
        'supplierName': supplierName,
        'purchaseType': purchaseType == PurchaseTypeFirestore.credit ? 'credit' : 'cash',
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory PurchaseFirestoreModel.fromFirestore(String id, Map<String, dynamic> data) {
    final typeStr = data['purchaseType'] as String? ?? 'cash';
    return PurchaseFirestoreModel(
      id: id,
      supplierId: data['supplierId'] as String? ?? '',
      supplierName: data['supplierName'] as String? ?? '',
      purchaseType: typeStr == 'credit' ? PurchaseTypeFirestore.credit : PurchaseTypeFirestore.cash,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: (data['paidAmount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (data['remainingAmount'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
