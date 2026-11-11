import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.taxPercent,
    required super.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      taxPercent: (json['taxPercent'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'taxPercent': taxPercent,
        'lineTotal': lineTotal,
      };
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.items,
    required super.orderType,
    required super.subtotal,
    required super.taxAmount,
    required super.total,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as String,
      items: itemsList
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderType: OrderType.values.firstWhere(
        (t) => t.name == json['orderType'],
        orElse: () => OrderType.cash,
      ),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => (e as OrderItemModel).toJson()).toList(),
        'orderType': orderType.name,
        'subtotal': subtotal,
        'taxAmount': taxAmount,
        'total': total,
        'createdAt': createdAt.toIso8601String(),
      };
}
