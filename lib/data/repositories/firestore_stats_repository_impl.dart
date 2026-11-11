import '../../domain/entities/financial_entity.dart';
import '../../domain/repositories/firestore_stats_repository.dart';
import '../datasources/firebase/firebase_category_datasource.dart';
import '../datasources/firebase/firebase_financial_summary_datasource.dart';
import '../datasources/firebase/firebase_order_datasource.dart';
import '../datasources/firebase/firebase_product_firestore_datasource.dart';

class FirestoreStatsRepositoryImpl implements FirestoreStatsRepository {
  FirestoreStatsRepositoryImpl({
    required FirebaseCategoryDataSource categoryDataSource,
    required FirebaseProductFirestoreDataSource productDataSource,
    required FirebaseOrderDataSource orderDataSource,
    required FirebaseFinancialSummaryDataSource financialSummaryDataSource,
  })  : _categoryDataSource = categoryDataSource,
        _productDataSource = productDataSource,
        _orderDataSource = orderDataSource,
        _financialSummaryDataSource = financialSummaryDataSource;

  final FirebaseCategoryDataSource _categoryDataSource;
  final FirebaseProductFirestoreDataSource _productDataSource;
  final FirebaseOrderDataSource _orderDataSource;
  final FirebaseFinancialSummaryDataSource _financialSummaryDataSource;

  @override
  Future<FirestoreStatsEntity> getStats() async {
    final categories = await _categoryDataSource.getAll();
    final productCount = await _productDataSource.count();
    final orderCount = await _orderDataSource.countOrders();
    final summary = await _financialSummaryDataSource.get();

    FinancialSummaryEntity? financial;
    if (summary != null) {
      financial = FinancialSummaryEntity(
        totalCash: summary.totalCash,
        totalCredit: summary.totalCredit,
        totalSales: summary.totalSales,
        taxesCollected: summary.totalTaxesCollected,
        inventoryValue: 0,
        totalOrders: orderCount,
        updatedAt: summary.updatedAt,
      );
    }

    return FirestoreStatsEntity(
      categoriesCount: categories.length,
      productsCount: productCount,
      ordersCount: orderCount,
      financialSummary: financial,
    );
  }
}
