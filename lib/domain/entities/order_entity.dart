import 'package:equatable/equatable.dart';

enum OrderType { cash, credit, bankTransfer, eWallet }

class OrderItemEntity extends Equatable {
  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.taxPercent,
    required this.lineTotal,
    this.priceSnapshot,
    this.taxSnapshot,
    this.total,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double taxPercent;
  final double lineTotal;
  final double? priceSnapshot;
  final double? taxSnapshot;
  final double? total;

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    unitPrice,
    taxPercent,
    lineTotal,
    priceSnapshot,
    taxSnapshot,
    total,
  ];
}

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.items,
    required this.orderType,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.createdAt,
    this.orderNumber,
    this.paidAmount,
    this.remainingAmount,
    this.createdByUid,
    this.createdByName,
    this.createdByEmail,
  });

  final String id;
  final List<OrderItemEntity> items;
  final OrderType orderType;
  final double subtotal;
  final double taxAmount;
  final double total;
  final DateTime createdAt;
  final String? orderNumber;
  final double? paidAmount;
  final double? remainingAmount;

  /// Firebase Auth UID of creator.
  final String? createdByUid;

  /// Creator display name (for UI).
  final String? createdByName;

  /// Creator email (for audit).
  final String? createdByEmail;

  @override
  List<Object?> get props => [
    id,
    items,
    orderType,
    subtotal,
    taxAmount,
    total,
    createdAt,
    orderNumber,
    paidAmount,
    remainingAmount,
    createdByUid,
    createdByName,
    createdByEmail,
  ];
}
