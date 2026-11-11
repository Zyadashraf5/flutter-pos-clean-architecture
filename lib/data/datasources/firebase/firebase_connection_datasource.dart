import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';

/// Data source for Firebase connection verification.
/// Writes to Firestore to confirm connectivity — no business logic.
abstract class FirebaseConnectionDataSource {
  /// Writes a document to collection [test] with field { status: "connected" }.
  /// Used to verify Firebase/Firestore connection.
  Future<void> writeConnectionTest();
}

class FirebaseConnectionDataSourceImpl implements FirebaseConnectionDataSource {
  FirebaseConnectionDataSourceImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  @override
  Future<void> writeConnectionTest() async {
    await _firestore
        .collection(FirestorePaths.test)
        .doc('connection')
        .set(<String, dynamic>{'status': 'connected'});
  }
}
