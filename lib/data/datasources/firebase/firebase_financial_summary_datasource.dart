import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../models/firestore/financial_summary_firestore_model.dart';

abstract class FirebaseFinancialSummaryDataSource {
  Stream<FinancialSummaryFirestoreModel?> watch();
  Future<FinancialSummaryFirestoreModel?> get();
  Future<void> set(FinancialSummaryFirestoreModel model);
  Future<void> updateInTransaction({
    double addToCash = 0,
    double addToCredit = 0,
    double addToSupplierDebt = 0,
    double addToSales = 0,
    double addToTaxesCollected = 0,
  });
}

class FirebaseFinancialSummaryDataSourceImpl
    implements FirebaseFinancialSummaryDataSource {
  FirebaseFinancialSummaryDataSourceImpl([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _doc => _firestore
      .collection(FirestorePaths.financialSummary)
      .doc(FirestorePaths.docFinancialSummary);

  @override
  Stream<FinancialSummaryFirestoreModel?> watch() {
    return _doc.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      data['id'] = snapshot.id;
      return FinancialSummaryFirestoreModel.fromFirestore(data);
    });
  }

  @override
  Future<FinancialSummaryFirestoreModel?> get() async {
    final snapshot = await _doc.get();
    final data = snapshot.data();
    if (data == null) return null;
    return FinancialSummaryFirestoreModel.fromFirestore(data);
  }

  @override
  Future<void> set(FinancialSummaryFirestoreModel model) async {
    await _doc.set(model.toFirestore());
  }

  /// Updates financial summary by reading current values, adding amounts, and writing back.
  /// Uses a simple read-then-write instead of runTransaction() because the Windows
  /// C++ Firestore SDK crashes (abort()) when transactions run alongside batch writes.
  /// This is safe for a single-user desktop app.
  @override
  Future<void> updateInTransaction({
    double addToCash = 0,
    double addToCredit = 0,
    double addToSupplierDebt = 0,
    double addToSales = 0,
    double addToTaxesCollected = 0,
  }) async {
    try {
      // Use atomic FieldValue.increment to safely accumulate values
      // without reading first. This avoids stale-read bugs and is safe
      // even when running alongside batch writes on Windows.
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      if (addToCash != 0) {
        updates['totalCash'] = FieldValue.increment(addToCash);
      }
      if (addToCredit != 0) {
        updates['totalCredit'] = FieldValue.increment(addToCredit);
      }
      if (addToSupplierDebt != 0) {
        updates['supplierDebt'] = FieldValue.increment(addToSupplierDebt);
      }
      if (addToSales != 0) {
        updates['totalSales'] = FieldValue.increment(addToSales);
      }
      if (addToTaxesCollected != 0) {
        updates['totalTaxesCollected'] = FieldValue.increment(
          addToTaxesCollected,
        );
      }
      await _doc.set(updates, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FinancialSummary] updateInTransaction FAILED: $e');
      }
      rethrow;
    }
  }
}
