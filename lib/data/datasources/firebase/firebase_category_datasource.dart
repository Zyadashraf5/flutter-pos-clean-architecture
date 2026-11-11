import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/firestore/category_firestore_model.dart';

abstract class FirebaseCategoryDataSource {
  Future<void> create(CategoryFirestoreModel model);
  Future<List<CategoryFirestoreModel>> getAll();
  Future<CategoryFirestoreModel?> getById(String id);
  Future<bool> hasAny();
}

class FirebaseCategoryDataSourceImpl implements FirebaseCategoryDataSource {
  FirebaseCategoryDataSourceImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coll =>
      _firestore.collection(FirestorePaths.categories);

  @override
  Future<void> create(CategoryFirestoreModel model) async {
    await _coll.doc(model.id).set(model.toFirestore());
  }

  @override
  Future<List<CategoryFirestoreModel>> getAll() async {
    final snapshot = await _coll.where('isActive', isEqualTo: true).get();
    final list = snapshot.docs
        .map((d) {
          final data = d.data();
          data['id'] = d.id;
          return CategoryFirestoreModel.fromFirestore(data);
        })
        .toList();
    AppLogger.dataSource('Category', 'getAll() returned ${list.length} documents');
    return list..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<CategoryFirestoreModel?> getById(String id) async {
    final doc = await _coll.doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    data['id'] = doc.id;
    return CategoryFirestoreModel.fromFirestore(data);
  }

  @override
  Future<bool> hasAny() async {
    final snapshot = await _coll.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }
}
