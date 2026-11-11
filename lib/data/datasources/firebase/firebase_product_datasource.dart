import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../models/product_model.dart';

/// Remote product data source using Firestore.
/// Used for sync / multi-user readiness; no business logic.
abstract class FirebaseProductDataSource {
  Future<void> create(ProductModel product);
  Future<void> update(ProductModel product);
  Future<void> delete(String id);
  Future<List<ProductModel>> getAll();
  Future<ProductModel?> getById(String id);
}

class FirebaseProductDataSourceImpl implements FirebaseProductDataSource {
  FirebaseProductDataSourceImpl([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.products);

  @override
  Future<void> create(ProductModel product) async {
    await _collection.doc(product.id).set(product.toJson());
  }

  @override
  Future<void> update(ProductModel product) async {
    // Use merge to avoid overwriting fields not present in ProductModel
    // (e.g. isActive, createdAt, updatedAt, taxPercentage) which are managed
    // by the Firestore-native schema.
    final data = product.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _collection.doc(product.id).set(data, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<List<ProductModel>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((d) => ProductModel.fromJson(d.data())).toList();
  }

  @override
  Future<ProductModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.data() == null) return null;
    return ProductModel.fromJson(doc.data()!);
  }
}
