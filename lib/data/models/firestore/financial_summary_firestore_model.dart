import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialSummaryFirestoreModel {
  const FinancialSummaryFirestoreModel({
    required this.totalSales,
    required this.totalCash,
    required this.totalCredit,
    required this.totalTaxesCollected,
    required this.updatedAt,
    this.supplierDebt = 0,
  });

  final double totalSales;
  final double totalCash;
  final double totalCredit;
  final double totalTaxesCollected;
  final double supplierDebt;
  final DateTime updatedAt;

  Map<String, dynamic> toFirestore() => {
        'totalSales': totalSales,
        'totalCash': totalCash,
        'totalCredit': totalCredit,
        'totalTaxesCollected': totalTaxesCollected,
        'supplierDebt': supplierDebt,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory FinancialSummaryFirestoreModel.fromFirestore(Map<String, dynamic> data) {
    return FinancialSummaryFirestoreModel(
      totalSales: (data['totalSales'] as num?)?.toDouble() ?? 0,
      totalCash: (data['totalCash'] as num?)?.toDouble() ?? 0,
      totalCredit: (data['totalCredit'] as num?)?.toDouble() ?? 0,
      totalTaxesCollected: (data['totalTaxesCollected'] as num?)?.toDouble() ?? 0,
      supplierDebt: (data['supplierDebt'] as num?)?.toDouble() ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
