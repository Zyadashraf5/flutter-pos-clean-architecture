import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/firestore/product_firestore_model.dart';

/// Firestore-native product datasource for enterprise schema (createdAt, updatedAt, isActive, taxPercentage).
abstract class FirebaseProductFirestoreDataSource {
  Future<void> create(ProductFirestoreModel model);
  Future<List<ProductFirestoreModel>> getAll();
  Future<ProductFirestoreModel?> getById(String id);
  Future<ProductFirestoreModel?> getByBarcode(String barcode);
  Future<int> count();
}

class FirebaseProductFirestoreDataSourceImpl
    implements FirebaseProductFirestoreDataSource {
  FirebaseProductFirestoreDataSourceImpl([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coll =>
      _firestore.collection(FirestorePaths.products);

  @override
  Future<void> create(ProductFirestoreModel model) async {
    await _coll.doc(model.id).set(model.toFirestore());
  }

  @override
  Future<List<ProductFirestoreModel>> getAll() async {
    final snapshot = await _coll.where('isActive', isEqualTo: true).get();
    final list = snapshot.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return ProductFirestoreModel.fromFirestore(data);
    }).toList();
    AppLogger.dataSource(
      'Product',
      'getAll() returned ${list.length} documents',
    );
    return list..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<ProductFirestoreModel?> getById(String id) async {
    final doc = await _coll.doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    data['id'] = doc.id;
    return ProductFirestoreModel.fromFirestore(data);
  }

  @override
  Future<ProductFirestoreModel?> getByBarcode(String barcode) async {
    final snapshot = await _coll
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final d = snapshot.docs.first;

    final data = d.data();
    data['id'] = d.id;
    return ProductFirestoreModel.fromFirestore(data);
  }

  @override
  Future<int> count() async {
    final snapshot = await _coll.get();
    return snapshot.docs.length;
  }
}
