import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../models/firestore/user_firestore_model.dart';

abstract class FirebaseUserDataSource {
  Future<UserFirestoreModel?> getUserByUid(String uid);
}

class FirebaseUserDataSourceImpl implements FirebaseUserDataSource {
  FirebaseUserDataSourceImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<UserFirestoreModel?> getUserByUid(String uid) async {
    final doc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return UserFirestoreModel.fromFirestore(doc.id, data);
  }
}
