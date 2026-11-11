import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_initializer.dart';
import '../../models/inventory_device_model.dart';

/// Remote datasource for inventory devices using Firestore.
abstract class FirebaseInventoryDeviceDataSource {
  Future<void> create(InventoryDeviceModel device);
  Future<void> update(InventoryDeviceModel device);
  Future<void> delete(String id);
  Future<List<InventoryDeviceModel>> getAll();
  Future<InventoryDeviceModel?> getById(String id);
  Future<InventoryDeviceModel?> getByBarcode(String barcode);
}

class FirebaseInventoryDeviceDataSourceImpl
    implements FirebaseInventoryDeviceDataSource {
  FirebaseInventoryDeviceDataSourceImpl([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.inventoryDevices);

  @override
  Future<void> create(InventoryDeviceModel device) async {
    final data = device.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _collection.doc(device.id).set(data);
  }

  @override
  Future<void> update(InventoryDeviceModel device) async {
    final data = device.toJson();
    data.remove('createdAt'); // preserve original timestamp
    await _collection.doc(device.id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<List<InventoryDeviceModel>> getAll() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return InventoryDeviceModel.fromJson(data);
    }).toList();
  }

  @override
  Future<InventoryDeviceModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    data['id'] = doc.id;
    return InventoryDeviceModel.fromJson(data);
  }

  @override
  Future<InventoryDeviceModel?> getByBarcode(String barcode) async {
    final snapshot = await _collection
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final d = snapshot.docs.first;
    final data = d.data();
    data['id'] = d.id;
    return InventoryDeviceModel.fromJson(data);
  }
}
