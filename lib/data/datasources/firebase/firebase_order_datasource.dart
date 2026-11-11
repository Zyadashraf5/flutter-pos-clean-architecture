import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/firestore/order_firestore_model.dart';
import '../../models/firestore/order_item_firestore_model.dart';

class OrderWithItems {
  OrderWithItems(this.order, this.items);
  final OrderFirestoreModel order;
  final List<OrderItemFirestoreModel> items;
}

abstract class FirebaseOrderDataSource {
  Future<void> createOrderWithItems(
    OrderFirestoreModel order,
    List<OrderItemFirestoreModel> items,
  );
  Future<List<OrderWithItems>> getAllOrdersWithItems();
  Future<int> countOrders();
  Future<void> deleteOrderWithItems(String orderId);
}

class FirebaseOrderDataSourceImpl implements FirebaseOrderDataSource {
  FirebaseOrderDataSourceImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ordersColl =>
      _firestore.collection(FirestorePaths.orders);

  @override
  Future<void> createOrderWithItems(
    OrderFirestoreModel order,
    List<OrderItemFirestoreModel> items,
  ) async {
    final orderRef = _ordersColl.doc(order.id);
    final batch = _firestore.batch();
    batch.set(orderRef, order.toFirestore());
    for (final item in items) {
      batch.set(
        orderRef.collection(FirestorePaths.orderItems).doc(),
        item.toFirestore(),
      );
    }
    await batch.commit();
  }

  @override
  Future<List<OrderWithItems>> getAllOrdersWithItems() async {
    final ordersSnapshot = await _ordersColl.orderBy('createdAt', descending: true).get();
    final result = <OrderWithItems>[];
    for (final doc in ordersSnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      final order = OrderFirestoreModel.fromFirestore(data);
      final itemsSnapshot = await doc.reference.collection(FirestorePaths.orderItems).get();
      final items = itemsSnapshot.docs
          .map((d) => OrderItemFirestoreModel.fromFirestore(d.data()))
          .toList();
      result.add(OrderWithItems(order, items));
    }
    AppLogger.dataSource('Order', 'getAllOrdersWithItems() returned ${result.length} orders');
    return result;
  }

  @override
  Future<int> countOrders() async {
    final snapshot = await _ordersColl.get();
    return snapshot.docs.length;
  }

  @override
  Future<void> deleteOrderWithItems(String orderId) async {
    final orderRef = _ordersColl.doc(orderId);
    final itemsSnapshot =
        await orderRef.collection(FirestorePaths.orderItems).get();
    final batch = _firestore.batch();
    for (final doc in itemsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(orderRef);
    await batch.commit();
  }
}
