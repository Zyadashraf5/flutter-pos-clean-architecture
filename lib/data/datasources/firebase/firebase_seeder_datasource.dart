import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/firebase/firebase_initializer.dart';
import '../../models/firestore/category_firestore_model.dart';
import '../../models/firestore/financial_summary_firestore_model.dart';
import '../../models/firestore/order_firestore_model.dart';
import '../../models/firestore/order_item_firestore_model.dart';
import '../../models/firestore/product_firestore_model.dart';
import '../../models/firestore/system_settings_firestore_model.dart';
import 'firebase_category_datasource.dart';
import 'firebase_financial_summary_datasource.dart';
import 'firebase_order_datasource.dart';
import 'firebase_product_firestore_datasource.dart';
import 'firebase_system_settings_datasource.dart';

/// Seeds Firestore with dummy data. No UI or business logic.
/// Uses batch writes and transactions. Idempotent (checks seed flag).
abstract class FirebaseSeederDataSource {
  Future<SeedResult> seed();
  Future<void> clear();
}

class SeedResult {
  const SeedResult({
    required this.success,
    required this.message,
    this.categoriesCount = 0,
    this.productsCount = 0,
    this.ordersCount = 0,
  });

  final bool success;
  final String message;
  final int categoriesCount;
  final int productsCount;
  final int ordersCount;
}

class FirebaseSeederDataSourceImpl implements FirebaseSeederDataSource {
  FirebaseSeederDataSourceImpl({
    required FirebaseCategoryDataSource categoryDataSource,
    required FirebaseProductFirestoreDataSource productDataSource,
    required FirebaseOrderDataSource orderDataSource,
    required FirebaseFinancialSummaryDataSource financialSummaryDataSource,
    required FirebaseSystemSettingsDataSource systemSettingsDataSource,
    FirebaseFirestore? firestore,
  })  : _categoryDataSource = categoryDataSource,
        _productDataSource = productDataSource,
        _orderDataSource = orderDataSource,
        _financialSummaryDataSource = financialSummaryDataSource,
        _systemSettingsDataSource = systemSettingsDataSource,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseCategoryDataSource _categoryDataSource;
  final FirebaseProductFirestoreDataSource _productDataSource;
  final FirebaseOrderDataSource _orderDataSource;
  final FirebaseFinancialSummaryDataSource _financialSummaryDataSource;
  final FirebaseSystemSettingsDataSource _systemSettingsDataSource;
  final FirebaseFirestore _firestore;

  static const int _categoryCount = 5;
  static const int _productCount = 20;
  static const int _orderCount = 10;

  @override
  Future<SeedResult> seed() async {
    try {
      final alreadySeeded = await _systemSettingsDataSource.isSeeded();
      if (alreadySeeded) {
        return const SeedResult(
          success: true,
          message: 'Database already seeded. Skipped to avoid duplicates.',
        );
      }

      final now = DateTime.now();
      final categories = _buildCategories(now);
      for (final c in categories) {
        await _categoryDataSource.create(c);
      }

      final products = _buildProducts(categories, now);
      for (final p in products) {
        await _productDataSource.create(p);
      }

      final rnd = Random(42);
      double totalSales = 0;
      double totalTax = 0;
      double totalCash = 0;
      double totalCredit = 0;

      for (var i = 0; i < _orderCount; i++) {
        final isCredit = rnd.nextBool();
        final orderWithItems = _buildOrder(i + 1, products, isCredit, rnd, now);
        await _orderDataSource.createOrderWithItems(
          orderWithItems.$1,
          orderWithItems.$2,
        );
        totalSales += orderWithItems.$1.total;
        totalTax += orderWithItems.$1.taxAmount;
        if (isCredit) {
          totalCredit += orderWithItems.$1.total;
        } else {
          totalCash += orderWithItems.$1.total;
        }
      }

      await _financialSummaryDataSource.set(FinancialSummaryFirestoreModel(
        totalSales: totalSales,
        totalCash: totalCash,
        totalCredit: totalCredit,
        totalTaxesCollected: totalTax,
        updatedAt: now,
      ));

      await _systemSettingsDataSource.set(SystemSettingsFirestoreModel(
        defaultTaxPercentage: AppConstants.defaultTaxPercent,
        currency: 'USD',
        lowStockThreshold: AppConstants.lowStockThreshold,
      ));
      await _systemSettingsDataSource.setSeeded();

      return SeedResult(
        success: true,
        message: 'Database seeded successfully.',
        categoriesCount: categories.length,
        productsCount: products.length,
        ordersCount: _orderCount,
      );
    } catch (e) {
      return SeedResult(
        success: false,
        message: 'Seed failed: $e',
      );
    }
  }

  List<CategoryFirestoreModel> _buildCategories(DateTime now) {
    const names = [
      'Electronics',
      'Groceries',
      'Clothing',
      'Home & Garden',
      'Sports',
    ];
    return List.generate(_categoryCount, (i) {
      final id = 'cat_seed_${i + 1}';
      return CategoryFirestoreModel(
        id: id,
        name: names[i],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );
    });
  }

  List<ProductFirestoreModel> _buildProducts(
    List<CategoryFirestoreModel> categories,
    DateTime now,
  ) {
    final products = <ProductFirestoreModel>[];
    final rnd = Random(24);
    for (var i = 0; i < _productCount; i++) {
      final cat = categories[i % categories.length];
      final price = 2.0 + rnd.nextDouble() * 98;
      final tax = (rnd.nextDouble() * 15).roundToDouble();
      products.add(ProductFirestoreModel(
        id: 'prod_seed_${i + 1}',
        name: 'Product ${i + 1} (${cat.name})',
        categoryId: cat.id,
        purchasePrice: price * 0.6,
        sellingPrice: price,
        quantity: 10 + rnd.nextInt(90),
        barcode: 'BAR${1000 + i}',
        taxPercentage: tax,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ));
    }
    return products;
  }

  (OrderFirestoreModel, List<OrderItemFirestoreModel>) _buildOrder(
    int orderIndex,
    List<ProductFirestoreModel> products,
    bool isCredit,
    Random rnd,
    DateTime now,
  ) {
    final itemCount = 1 + rnd.nextInt(4);
    final selected = <ProductFirestoreModel>[];
    final used = <int>{};
    for (var i = 0; i < itemCount; i++) {
      int idx;
      do {
        idx = rnd.nextInt(products.length);
      } while (used.contains(idx));
      used.add(idx);
      selected.add(products[idx]);
    }

    final items = <OrderItemFirestoreModel>[];
    double subtotal = 0;
    double taxAmount = 0;
    for (final p in selected) {
      final qty = 1 + rnd.nextInt(3);
      final linePrice = p.sellingPrice * qty;
      final lineTax = linePrice * (p.taxPercentage / 100);
      subtotal += linePrice;
      taxAmount += lineTax;
      items.add(OrderItemFirestoreModel(
        productId: p.id,
        productNameSnapshot: p.name,
        quantity: qty,
        priceSnapshot: p.sellingPrice,
        taxSnapshot: lineTax,
        total: linePrice + lineTax,
      ));
    }
    final total = subtotal + taxAmount;
    final paidAmount = isCredit ? 0.0 : total;
    final remainingAmount = isCredit ? total : 0.0;

    final order = OrderFirestoreModel(
      id: 'ord_seed_$orderIndex',
      orderNumber: 'ORD-${1000 + orderIndex}',
      orderType: isCredit ? OrderTypeFirestore.credit : OrderTypeFirestore.cash,
      subtotal: subtotal,
      taxAmount: taxAmount,
      total: total,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      createdAt: now.add(Duration(minutes: orderIndex)),
      createdByUid: 'seeder',
    );
    return (order, items);
  }

  @override
  Future<void> clear() async {
    final batch = _firestore.batch();

    final categoriesSnap = await _firestore.collection(FirestorePaths.categories).get();
    for (final doc in categoriesSnap.docs) {
      batch.delete(doc.reference);
    }

    final productsSnap = await _firestore.collection(FirestorePaths.products).get();
    for (final doc in productsSnap.docs) {
      batch.delete(doc.reference);
    }

    final ordersSnap = await _firestore.collection(FirestorePaths.orders).get();
    for (final doc in ordersSnap.docs) {
      batch.delete(doc.reference);
      final itemsSnap = await doc.reference.collection(FirestorePaths.orderItems).get();
      for (final itemDoc in itemsSnap.docs) {
        batch.delete(itemDoc.reference);
      }
    }

    final financialRef = _firestore
        .collection(FirestorePaths.financialSummary)
        .doc(FirestorePaths.docFinancialSummary);
    batch.delete(financialRef);

    final settingsRef = _firestore
        .collection(FirestorePaths.systemSettings)
        .doc(FirestorePaths.docSystemSettings);
    batch.delete(settingsRef);

    final seedRef = _firestore
        .collection(FirestorePaths.systemSettings)
        .doc(FirestorePaths.docSeedFlag);
    batch.delete(seedRef);

    await batch.commit();
  }
}
