import 'package:equatable/equatable.dart';

enum PurchaseType { cash, credit }

class PurchaseItemEntity extends Equatable {
  const PurchaseItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double purchasePrice;

  double get lineTotal => quantity * purchasePrice;

  @override
  List<Object?> get props => [productId, productName, quantity, purchasePrice];
}

class PurchaseEntity extends Equatable {
  const PurchaseEntity({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseType,
    required this.items,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.createdAt,
  });

  final String id;
  final String supplierId;
  final String supplierName;
  final PurchaseType purchaseType;
  final List<PurchaseItemEntity> items;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, supplierId, supplierName, purchaseType, items, totalAmount, paidAmount, remainingAmount, createdAt];
}
