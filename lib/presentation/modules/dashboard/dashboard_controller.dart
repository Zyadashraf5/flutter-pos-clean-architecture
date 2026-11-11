import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/financial_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../../domain/usecases/financial/get_financial_summary.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/order/get_orders.dart';

class DashboardController extends GetxController {
  DashboardController(
    this._getFinancialSummary,
    this._getOrders,
    this._getDevices,
  );

  final GetFinancialSummary _getFinancialSummary;
  final GetOrders _getOrders;
  final GetInventoryDevices _getDevices;

  final summary = Rxn<FinancialSummaryEntity>();
  final orders = <OrderEntity>[].obs;
  final devices = <InventoryDeviceEntity>[].obs;
  final loading = false.obs;

  @override
  void onReady() {
    loadSummary();
    super.onReady();
  }

  Future<void> loadSummary() async {
    loading.value = true;
    try {
      final results = await Future.wait([
        _getFinancialSummary(),
        _getOrders(),
        _getDevices(),
      ]);
      summary.value = results[0] as FinancialSummaryEntity;
      orders.assignAll(results[1] as List<OrderEntity>);
      devices.assignAll(results[2] as List<InventoryDeviceEntity>);
      AppLogger.controller(
        'Dashboard',
        'loadSummary() done – ${orders.length} orders, ${devices.length} devices',
      );
    } catch (e) {
      AppLogger.controller('Dashboard', 'loadSummary() failed', e);
    } finally {
      loading.value = false;
    }
  }

  // ── Chart data helpers ──

  /// Daily sales for the last 7 days.
  Map<DateTime, double> get dailySales {
    final now = DateTime.now();
    final map = <DateTime, double>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      map[day] = 0;
    }
    for (final o in orders) {
      final day = DateTime(
        o.createdAt.year,
        o.createdAt.month,
        o.createdAt.day,
      );
      if (map.containsKey(day)) {
        map[day] = map[day]! + o.total;
      }
    }
    return map;
  }

  /// Cash vs Credit vs Transfer totals.
  ({double cash, double credit, double transfer}) get paymentTotals {
    double cash = 0, credit = 0, transfer = 0;
    for (final o in orders) {
      switch (o.orderType) {
        case OrderType.cash:
          cash += o.total;
        case OrderType.credit:
          credit += o.total;
        case OrderType.bankTransfer:
        case OrderType.eWallet:
          transfer += o.total;
      }
    }
    return (cash: cash, credit: credit, transfer: transfer);
  }

  /// Top 5 products by total revenue from orders.
  List<({String name, double revenue})> get topProducts {
    final map = <String, ({String name, double revenue})>{};
    for (final o in orders) {
      for (final item in o.items) {
        final existing = map[item.productId];
        final name = item.productName;
        final rev = (existing?.revenue ?? 0) + item.lineTotal;
        map[item.productId] = (name: name, revenue: rev);
      }
    }
    final sorted = map.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    return sorted.take(5).toList();
  }
}
