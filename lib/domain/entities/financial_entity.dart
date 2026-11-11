import 'package:equatable/equatable.dart';

class FinancialSummaryEntity extends Equatable {
  const FinancialSummaryEntity({
    required this.totalCash,
    required this.totalCredit,
    required this.totalSales,
    required this.taxesCollected,
    required this.inventoryValue,
    required this.totalOrders,
    this.supplierDebt = 0,
    this.updatedAt,
  });

  final double totalCash;
  final double totalCredit;
  final double totalSales;
  final double taxesCollected;
  final double inventoryValue;
  final int totalOrders;
  /// Total outstanding debt to suppliers (credit purchases not yet paid).
  final double supplierDebt;
  final DateTime? updatedAt;

  /// Gross revenue (same as totalSales).
  double get grossRevenue => totalSales;

  /// Net profit: revenue minus taxes. (COGS not tracked per sale; inventory value is separate.)
  double get netProfit => totalSales - taxesCollected;

  @override
  List<Object?> get props =>
      [totalCash, totalCredit, totalSales, taxesCollected, inventoryValue, totalOrders, supplierDebt, updatedAt];
}
