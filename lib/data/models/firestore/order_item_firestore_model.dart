import '../../../core/utils/firestore_safe.dart';

class OrderItemFirestoreModel {
  const OrderItemFirestoreModel({
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.priceSnapshot,
    required this.taxSnapshot,
    required this.total,
  });

  final String productId;
  final String productNameSnapshot;
  final int quantity;
  final double priceSnapshot;
  final double taxSnapshot;
  final double total;

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'productNameSnapshot': productNameSnapshot,
        'quantity': quantity,
        'priceSnapshot': FirestoreSafe.doubleValue(priceSnapshot),
        'taxSnapshot': FirestoreSafe.doubleValue(taxSnapshot),
        'total': FirestoreSafe.doubleValue(total),
      };

  factory OrderItemFirestoreModel.fromFirestore(Map<String, dynamic> data) {
    return OrderItemFirestoreModel(
      productId: data['productId'] as String,
      productNameSnapshot: data['productNameSnapshot'] as String,
      quantity: data['quantity'] as int,
      priceSnapshot: (data['priceSnapshot'] as num).toDouble(),
      taxSnapshot: (data['taxSnapshot'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
    );
  }
}
