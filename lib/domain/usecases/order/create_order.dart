import 'package:flutter/foundation.dart';

import '../../entities/order_entity.dart'
    show OrderEntity, OrderItemEntity, OrderType;
import '../../repositories/financial_repository.dart';
import '../../repositories/inventory_device_repository.dart';
import '../../repositories/order_repository.dart';

/// Orchestrates order creation through validated, isolated steps.
///
/// The order is saved first; inventory and financial updates only run once
/// the sale exists, so a failed save can never leave sold devices or revenue
/// without a matching order. Those follow-up steps are wrapped individually so
/// a single failure does not crash the app (especially the Windows C++
/// Firestore SDK).
class CreateOrder {
  CreateOrder(
    this._orderRepository,
    this._inventoryDeviceRepository,
    this._financialRepository,
  );

  final OrderRepository _orderRepository;
  final InventoryDeviceRepository _inventoryDeviceRepository;
  final FinancialRepository _financialRepository;

  Future<void> call(OrderEntity order) async {
    _validateOrder(order);

    final totals = _calculateTotals(order);

    final safeOrder = OrderEntity(
      id: order.id,
      items: order.items,
      orderType: order.orderType,
      subtotal: totals.subtotal,
      taxAmount: totals.taxAmount,
      total: totals.total,
      createdAt: order.createdAt,
      orderNumber: order.orderNumber,
      paidAmount: order.paidAmount,
      remainingAmount: order.remainingAmount,
      createdByUid: order.createdByUid,
      createdByName: order.createdByName,
      createdByEmail: order.createdByEmail,
    );

    // Step 1: Persist the order first. If this fails nothing else has been
    // touched, so inventory and the financial summary stay consistent.
    await _saveOrder(safeOrder);

    // Step 2: Mark devices as sold in inventory (best effort, logged on failure).
    await _markDevicesAsSold(safeOrder.items);

    // Step 3: Update the financial summary (best effort, logged on failure).
    await _updateFinancials(
      safeOrder.orderType,
      totals.total,
      totals.taxAmount,
    );
  }

  void _validateOrder(OrderEntity order) {
    if (order.items.isEmpty) {
      throw OrderValidationException('Cannot create order with empty items.');
    }
    for (final item in order.items) {
      if (item.quantity <= 0) {
        throw OrderValidationException(
          'Item "${item.productName}" has invalid quantity: ${item.quantity}',
        );
      }
      if (!item.unitPrice.isFinite || item.unitPrice < 0) {
        throw OrderValidationException(
          'Item "${item.productName}" has invalid price: ${item.unitPrice}',
        );
      }
      if (!item.taxPercent.isFinite || item.taxPercent < 0) {
        throw OrderValidationException(
          'Item "${item.productName}" has invalid tax: ${item.taxPercent}',
        );
      }
      if (!item.lineTotal.isFinite || item.lineTotal < 0) {
        throw OrderValidationException(
          'Item "${item.productName}" has invalid line total: ${item.lineTotal}',
        );
      }
    }
  }

  _OrderTotals _calculateTotals(OrderEntity order) {
    double subtotal = 0;
    double taxAmount = 0;
    for (final item in order.items) {
      final lineSub = _safeDouble(item.unitPrice * item.quantity);
      final lineTax = _safeDouble(lineSub * (item.taxPercent / 100));
      subtotal += lineSub;
      taxAmount += lineTax;
    }
    subtotal = _safeDouble(subtotal);
    taxAmount = _safeDouble(taxAmount);
    final total = _safeDouble(subtotal + taxAmount);
    return _OrderTotals(subtotal: subtotal, taxAmount: taxAmount, total: total);
  }

  /// Mark each device as sold in inventory.
  Future<void> _markDevicesAsSold(List<OrderItemEntity> items) async {
    for (final item in items) {
      try {
        final device = await _inventoryDeviceRepository.getById(item.productId);
        if (device != null) {
          final sold = device.copyWith(
            isSold: true,
            sellingPrice: item.unitPrice,
          );
          await _inventoryDeviceRepository.update(sold);
        }
      } catch (e, st) {
        debugPrint(
          '[CreateOrder] markDeviceAsSold FAILED for ${item.productId}: $e',
        );
        debugPrint(st.toString());
      }
    }
  }

  Future<void> _updateFinancials(
    OrderType type,
    double total,
    double taxAmount,
  ) async {
    if (total <= 0) return;
    try {
      if (type == OrderType.credit) {
        await _financialRepository.addToCredit(total);
      } else {
        // cash, bankTransfer, eWallet all count as immediate payment
        await _financialRepository.addToCash(total);
      }
    } catch (e, st) {
      debugPrint('[CreateOrder] updateFinancials FAILED: $e');
      debugPrint(st.toString());
    }
    // Record totalSales and taxesCollected
    try {
      await _financialRepository.recordSale(total, taxAmount);
    } catch (e, st) {
      debugPrint('[CreateOrder] recordSale FAILED: $e');
      debugPrint(st.toString());
    }
  }

  Future<void> _saveOrder(OrderEntity order) async {
    try {
      await _orderRepository.create(order);
    } catch (e, st) {
      debugPrint('[CreateOrder] saveOrder FAILED: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  static double _safeDouble(double v) => v.isFinite ? v : 0.0;
}

class _OrderTotals {
  const _OrderTotals({
    required this.subtotal,
    required this.taxAmount,
    required this.total,
  });
  final double subtotal;
  final double taxAmount;
  final double total;
}

class OrderValidationException implements Exception {
  OrderValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}
