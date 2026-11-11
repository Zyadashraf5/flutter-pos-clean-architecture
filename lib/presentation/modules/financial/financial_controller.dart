import 'dart:async';

import 'package:get/get.dart';

import '../../../domain/auth/permission.dart';
import '../../../domain/entities/financial_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../../domain/usecases/financial/get_financial_summary.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/order/get_orders.dart';
import '../../../domain/usecases/settings/get_default_tax.dart';
import '../../../domain/repositories/financial_repository.dart';
import '../../../domain/usecases/settings/set_default_tax.dart';
import '../../auth/auth_controller.dart';

class FinancialController extends GetxController {
  FinancialController(
    this._financialRepository,
    this._getFinancialSummary,
    this._getOrders,
    this._getDevices,
    this._getDefaultTax,
    this._setDefaultTax,
  );

  final FinancialRepository _financialRepository;
  final GetFinancialSummary _getFinancialSummary;
  final GetOrders _getOrders;
  final GetInventoryDevices _getDevices;
  final GetDefaultTax _getDefaultTax;
  final SetDefaultTax _setDefaultTax;

  final summary = Rxn<FinancialSummaryEntity>();
  final defaultTaxPercent = 0.0.obs;
  final loading = false.obs;

  final todaysSales = 0.0.obs;
  final monthSales = 0.0.obs;
  final topSellingProducts = <_ProductSale>[].obs;
  final cashTotal = 0.0.obs;
  final creditTotal = 0.0.obs;
  final mostProfitableCategoryName = Rx<String?>(null);
  final monthlySales = <double>[].obs;
  final dailySales = <_DaySale>[].obs;

  StreamSubscription<FinancialSummaryEntity>? _summarySub;
  List<OrderEntity> _orders = [];
  List<InventoryDeviceEntity> _devices = [];

  @override
  void onReady() {
    loadDefaultTax();
    loadSummaryStream();
    loadOrdersAndAnalytics();
    super.onReady();
  }

  @override
  void onClose() {
    _summarySub?.cancel();
    super.onClose();
  }

  void loadSummaryStream() {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.viewFinancial)) {
      return;
    }
    loading.value = true;
    _summarySub?.cancel();
    _summarySub = _financialRepository.watchSummary().listen(
      (s) {
        summary.value = s;
        loading.value = false;
      },
      onError: (_) {
        loadSummaryOnce();
      },
    );
  }

  Future<void> loadSummaryOnce() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.viewFinancial)) {
      return;
    }
    loading.value = true;
    try {
      summary.value = await _getFinancialSummary();
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadDefaultTax() async {
    defaultTaxPercent.value = await _getDefaultTax();
  }

  Future<void> saveDefaultTax(double value) async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.viewFinancial)) {
      return;
    }
    await _setDefaultTax(value);
    defaultTaxPercent.value = value;
  }

  Future<void> loadOrdersAndAnalytics() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.viewFinancial)) {
      return;
    }
    try {
      _orders = await _getOrders();
      _devices = await _getDevices();
      _computeAnalytics();
    } catch (_) {}
  }

  void _computeAnalytics() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    double today = 0, month = 0, cash = 0, credit = 0;
    final productQuantities = <String, int>{};
    final productNames = <String, String>{};
    final categoryTotals = <String, double>{};
    final categoryNames = <String, String>{};

    for (final d in _devices) {
      productNames[d.id] = d.deviceName;
      if (d.categoryId != null) {
        categoryNames[d.categoryId!] = d.categoryId!;
      }
    }

    for (final o in _orders) {
      if (!o.createdAt.isBefore(todayStart)) today += o.total;
      if (!o.createdAt.isBefore(monthStart)) month += o.total;
      if (o.orderType == OrderType.cash) {
        cash += o.total;
      } else {
        credit += o.total;
      }
      for (final item in o.items) {
        productQuantities[item.productId] =
            (productQuantities[item.productId] ?? 0) + item.quantity;
        if (!productNames.containsKey(item.productId)) {
          productNames[item.productId] = item.productName;
        }
        final catId = _devices
            .where((d) => d.id == item.productId)
            .firstOrNull
            ?.categoryId;
        if (catId != null) {
          categoryTotals[catId] = (categoryTotals[catId] ?? 0) + item.lineTotal;
          if (!categoryNames.containsKey(catId)) categoryNames[catId] = catId;
        }
      }
    }

    todaysSales.value = today;
    monthSales.value = month;
    cashTotal.value = cash;
    creditTotal.value = credit;

    final topList =
        productQuantities.entries
            .map(
              (e) => _ProductSale(e.key, productNames[e.key] ?? e.key, e.value),
            )
            .toList()
          ..sort((a, b) => b.quantity.compareTo(a.quantity));
    topSellingProducts.assignAll(topList.take(5));

    if (categoryTotals.isNotEmpty) {
      final topCat = categoryTotals.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      mostProfitableCategoryName.value =
          categoryNames[topCat.key] ?? topCat.key;
    } else {
      mostProfitableCategoryName.value = null;
    }

    final months = <double>[];
    for (var i = 11; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final next = DateTime(d.year, d.month + 1, 1);
      double sum = 0;
      for (final o in _orders) {
        if (!o.createdAt.isBefore(d) && o.createdAt.isBefore(next)) {
          sum += o.total;
        }
      }
      months.add(sum);
    }
    monthlySales.assignAll(months);

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dayList = <_DaySale>[];
    for (var d = 1; d <= daysInMonth; d++) {
      final dayStart = DateTime(now.year, now.month, d);
      final dayEnd = DateTime(now.year, now.month, d, 23, 59, 59);
      double sum = 0;
      for (final o in _orders) {
        if (!o.createdAt.isBefore(dayStart) && !o.createdAt.isAfter(dayEnd)) {
          sum += o.total;
        }
      }
      dayList.add(_DaySale(d, sum));
    }
    dailySales.assignAll(dayList);
  }

  double get creditVsCashTotal => cashTotal.value + creditTotal.value;
}

class _DaySale {
  _DaySale(this.day, this.total);
  final int day;
  final double total;
}

class _ProductSale {
  _ProductSale(this.productId, this.productName, this.quantity);
  final String productId;
  final String productName;
  final int quantity;
}
