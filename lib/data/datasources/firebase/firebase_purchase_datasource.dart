import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../models/firestore/purchase_firestore_model.dart';

class PurchaseWithItems {
  PurchaseWithItems(this.purchase, this.items);
  final PurchaseFirestoreModel purchase;
  final List<PurchaseItemFirestoreModel> items;
}

abstract class FirebasePurchaseDataSource {
  Future<void> createPurchaseWithItems(
    PurchaseFirestoreModel purchase,
    List<PurchaseItemFirestoreModel> items,
  );
  Future<List<PurchaseWithItems>> getAllPurchasesWithItems();
  Future<List<PurchaseWithItems>> getPurchasesByDateRange(DateTime start, DateTime end);
}

class FirebasePurchaseDataSourceImpl implements FirebasePurchaseDataSource {
  FirebasePurchaseDataSourceImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coll =>
      _firestore.collection(FirestorePaths.purchases);

  @override
  Future<void> createPurchaseWithItems(
    PurchaseFirestoreModel purchase,
    List<PurchaseItemFirestoreModel> items,
  ) async {
    final batch = _firestore.batch();
    final purchaseRef = _coll.doc(purchase.id);
    batch.set(purchaseRef, purchase.toFirestore());
    for (final item in items) {
      batch.set(
        purchaseRef.collection(FirestorePaths.purchaseItems).doc(),
        item.toFirestore(),
      );
    }
    await batch.commit();
  }

  @override
  Future<List<PurchaseWithItems>> getAllPurchasesWithItems() async {
    final snapshot = await _coll.orderBy('createdAt', descending: true).get();
    final result = <PurchaseWithItems>[];
    for (final doc in snapshot.docs) {
      final purchase = PurchaseFirestoreModel.fromFirestore(doc.id, doc.data());
      final itemsSnap = await doc.reference.collection(FirestorePaths.purchaseItems).get();
      final items = itemsSnap.docs
          .map((d) => PurchaseItemFirestoreModel.fromFirestore(d.data()))
          .toList();
      result.add(PurchaseWithItems(purchase, items));
    }
    return result;
  }

  @override
  Future<List<PurchaseWithItems>> getPurchasesByDateRange(DateTime start, DateTime end) async {
    final all = await getAllPurchasesWithItems();
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return all.where((p) {
      final t = p.purchase.createdAt;
      return !t.isBefore(startDay) && !t.isAfter(endDay);
    }).toList();
  }
}
