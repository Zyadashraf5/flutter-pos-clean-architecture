import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../models/firestore/system_settings_firestore_model.dart';

abstract class FirebaseSystemSettingsDataSource {
  Future<SystemSettingsFirestoreModel?> get();
  Future<void> set(SystemSettingsFirestoreModel model);
  Future<bool> isSeeded();
  Future<void> setSeeded();
}

class FirebaseSystemSettingsDataSourceImpl
    implements FirebaseSystemSettingsDataSource {
  FirebaseSystemSettingsDataSourceImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _settingsDoc => _firestore
      .collection(FirestorePaths.systemSettings)
      .doc(FirestorePaths.docSystemSettings);

  DocumentReference<Map<String, dynamic>> get _seedDoc => _firestore
      .collection(FirestorePaths.systemSettings)
      .doc(FirestorePaths.docSeedFlag);

  @override
  Future<SystemSettingsFirestoreModel?> get() async {
    final snapshot = await _settingsDoc.get();
    final data = snapshot.data();
    if (data == null) return null;
    return SystemSettingsFirestoreModel.fromFirestore(data);
  }

  @override
  Future<void> set(SystemSettingsFirestoreModel model) async {
    await _settingsDoc.set(model.toFirestore());
  }

  @override
  Future<bool> isSeeded() async {
    final snapshot = await _seedDoc.get();
    return snapshot.exists && (snapshot.data()?['seeded'] == true);
  }

  @override
  Future<void> setSeeded() async {
    await _seedDoc.set({
      'seeded': true,
      'seededAt': FieldValue.serverTimestamp(),
    });
  }
}
