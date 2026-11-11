import '../entities/financial_entity.dart';

/// Stats from Firestore for admin/dashboard. Domain only.
class FirestoreStatsEntity {
  const FirestoreStatsEntity({
    required this.categoriesCount,
    required this.productsCount,
    required this.ordersCount,
    this.financialSummary,
  });

  final int categoriesCount;
  final int productsCount;
  final int ordersCount;
  final FinancialSummaryEntity? financialSummary;
}

abstract class FirestoreStatsRepository {
  Future<FirestoreStatsEntity> getStats();
}
