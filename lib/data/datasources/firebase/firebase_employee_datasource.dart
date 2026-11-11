import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../models/firestore/employee_firestore_model.dart';

abstract class FirebaseEmployeeDataSource {
  Future<EmployeeFirestoreModel?> getByEmail(String email);
  Future<EmployeeFirestoreModel?> getById(String id);
  Future<List<EmployeeFirestoreModel>> getAll();
  Future<void> create(EmployeeFirestoreModel model);
  Future<void> update(EmployeeFirestoreModel model);
  Future<void> updateLastLoginAt(String id, DateTime at);
}

class FirebaseEmployeeDataSourceImpl implements FirebaseEmployeeDataSource {
  FirebaseEmployeeDataSourceImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coll =>
      _firestore.collection(FirestorePaths.employees);

  @override
  Future<EmployeeFirestoreModel?> getByEmail(String email) async {
    final snapshot = await _coll.where('email', isEqualTo: email.toLowerCase().trim()).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return EmployeeFirestoreModel.fromFirestore(doc.id, doc.data());
  }

  @override
  Future<EmployeeFirestoreModel?> getById(String id) async {
    final doc = await _coll.doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    return EmployeeFirestoreModel.fromFirestore(doc.id, data);
  }

  @override
  Future<List<EmployeeFirestoreModel>> getAll() async {
    final snapshot = await _coll.orderBy('name').get();
    return snapshot.docs
        .map((d) => EmployeeFirestoreModel.fromFirestore(d.id, d.data()))
        .toList();
  }

  @override
  Future<void> create(EmployeeFirestoreModel model) async {
    await _coll.doc(model.id).set(model.toFirestore());
  }

  @override
  Future<void> update(EmployeeFirestoreModel model) async {
    await _coll.doc(model.id).set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> updateLastLoginAt(String id, DateTime at) async {
    await _coll.doc(id).set({'lastLoginAt': Timestamp.fromDate(at)}, SetOptions(merge: true));
  }
}
