import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../models/firestore/supplier_firestore_model.dart';

abstract class FirebaseSupplierDataSource {
  Future<List<SupplierFirestoreModel>> getAll();
  Future<SupplierFirestoreModel?> getById(String id);
  Future<void> create(SupplierFirestoreModel model);
  Future<void> update(SupplierFirestoreModel model);
  Future<void> delete(String id);
  Future<void> updateDebt(String id, double addDebt, double addPaid);
}

class FirebaseSupplierDataSourceImpl implements FirebaseSupplierDataSource {
  FirebaseSupplierDataSourceImpl([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coll =>
      _firestore.collection(FirestorePaths.suppliers);

  @override
  Future<List<SupplierFirestoreModel>> getAll() async {
    final snapshot = await _coll.orderBy('name').get();
    return snapshot.docs
        .map((d) => SupplierFirestoreModel.fromFirestore(d.id, d.data()))
        .toList();
  }

  @override
  Future<SupplierFirestoreModel?> getById(String id) async {
    final doc = await _coll.doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    return SupplierFirestoreModel.fromFirestore(doc.id, data);
  }

  @override
  Future<void> create(SupplierFirestoreModel model) async {
    await _coll.doc(model.id).set(model.toFirestore());
  }

  @override
  Future<void> update(SupplierFirestoreModel model) async {
    await _coll.doc(model.id).set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> delete(String id) async {
    await _coll.doc(id).delete();
  }

  @override
  Future<void> updateDebt(String id, double addDebt, double addPaid) async {
    // Use atomic FieldValue.increment to safely accumulate debt/paid
    // even if multiple writes happen or cached reads return stale data.
    await _coll.doc(id).set({
      if (addDebt != 0) 'totalDebt': FieldValue.increment(addDebt),
      if (addPaid != 0) 'totalPaid': FieldValue.increment(addPaid),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }
}
