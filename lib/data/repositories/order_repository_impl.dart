import 'package:flutter/foundation.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/firebase/firebase_order_datasource.dart';
import '../datasources/local/order_local_datasource.dart';
import '../models/firestore/order_firestore_model.dart';
import '../models/firestore/order_item_firestore_model.dart';
import '../models/order_model.dart';
import '../../core/utils/app_logger.dart';

/// Reads from Firestore first so seeded/remote data is visible. Writes to local (and optionally Firestore).
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._local, {FirebaseOrderDataSource? firestore})
    : _firestore = firestore;

  final OrderLocalDatasource _local;
  final FirebaseOrderDataSource? _firestore;

  @override
  Future<List<OrderEntity>> getAll() async {
    if (_firestore != null) {
      try {
        final list = await _firestore.getAllOrdersWithItems();
        AppLogger.repository(
          'Order',
          'getAll() from Firestore: ${list.length} orders',
        );
        return list.map(_orderWithItemsToEntity).toList();
      } catch (e, st) {
        if (kDebugMode) {
          AppLogger.repository(
            'Order',
            'getAll() Firestore failed, fallback to local',
            e,
          );
          debugPrint(st.toString());
        }
      }
    }
    final local = await _local.getAll();
    AppLogger.repository(
      'Order',
      'getAll() from local: ${local.length} orders',
    );
    return local;
  }

  @override
  Future<OrderEntity?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> create(OrderEntity order) async {
    await _local.create(
      OrderModel(
        id: order.id,
        items: order.items
            .map(
              (e) => OrderItemModel(
                productId: e.productId,
                productName: e.productName,
                quantity: e.quantity,
                unitPrice: e.unitPrice,
                taxPercent: e.taxPercent,
                lineTotal: e.lineTotal,
              ),
            )
            .toList(),
        orderType: order.orderType,
        subtotal: order.subtotal,
        taxAmount: order.taxAmount,
        total: order.total,
        createdAt: order.createdAt,
      ),
    );
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final orderNumber =
            order.orderNumber ??
            'ORD-${order.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}';
        final paidAmount = order.orderType == OrderType.credit
            ? 0.0
            : order.total;
        final remainingAmount = order.orderType == OrderType.credit
            ? order.total
            : 0.0;
        final orderModel = OrderFirestoreModel(
          id: order.id,
          orderNumber: orderNumber,
          orderType: _toFirestoreOrderType(order.orderType),
          subtotal: order.subtotal,
          taxAmount: order.taxAmount,
          total: order.total,
          paidAmount: paidAmount,
          remainingAmount: remainingAmount,
          createdAt: order.createdAt,
          createdByUid: order.createdByUid ?? '',
          createdByName: order.createdByName,
          createdByEmail: order.createdByEmail,
        );
        final items = order.items
            .map(
              (e) => OrderItemFirestoreModel(
                productId: e.productId,
                productNameSnapshot: e.productName,
                quantity: e.quantity,
                priceSnapshot: e.unitPrice,
                taxSnapshot: e.unitPrice * e.quantity * (e.taxPercent / 100),
                total: e.lineTotal,
              ),
            )
            .toList();
        await firestore.createOrderWithItems(orderModel, items);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OrderRepo] Firestore createOrderWithItems FAILED: $e');
        }
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore.deleteOrderWithItems(id);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OrderRepo] Firestore deleteOrderWithItems FAILED: $e');
        }
      }
    }
  }

  OrderEntity _orderWithItemsToEntity(OrderWithItems o) {
    final order = o.order;
    final orderType = _fromFirestoreOrderType(order.orderType);
    final items = o.items.map((item) {
      final taxPercent = item.priceSnapshot > 0 && item.quantity > 0
          ? (item.taxSnapshot / (item.priceSnapshot * item.quantity)) * 100
          : 0.0;
      return OrderItemEntity(
        productId: item.productId,
        productName: item.productNameSnapshot,
        quantity: item.quantity,
        unitPrice: item.priceSnapshot,
        taxPercent: taxPercent,
        lineTotal: item.total,
        priceSnapshot: item.priceSnapshot,
        taxSnapshot: item.taxSnapshot,
        total: item.total,
      );
    }).toList();
    return OrderEntity(
      id: order.id,
      items: items,
      orderType: orderType,
      subtotal: order.subtotal,
      taxAmount: order.taxAmount,
      total: order.total,
      createdAt: order.createdAt,
      orderNumber: order.orderNumber,
      paidAmount: order.paidAmount,
      remainingAmount: order.remainingAmount,
      createdByUid: order.createdByUid,
      createdByName: order.createdByName,
      createdByEmail: order.createdByEmail,
    );
  }

  static OrderTypeFirestore _toFirestoreOrderType(OrderType type) {
    switch (type) {
      case OrderType.cash:
        return OrderTypeFirestore.cash;
      case OrderType.credit:
        return OrderTypeFirestore.credit;
      case OrderType.bankTransfer:
        return OrderTypeFirestore.bankTransfer;
      case OrderType.eWallet:
        return OrderTypeFirestore.eWallet;
    }
  }

  static OrderType _fromFirestoreOrderType(OrderTypeFirestore type) {
    switch (type) {
      case OrderTypeFirestore.cash:
        return OrderType.cash;
      case OrderTypeFirestore.credit:
        return OrderType.credit;
      case OrderTypeFirestore.bankTransfer:
        return OrderType.bankTransfer;
      case OrderTypeFirestore.eWallet:
        return OrderType.eWallet;
    }
  }
}
