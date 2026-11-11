import 'package:flutter/foundation.dart';

import '../../domain/entities/inventory_device_entity.dart';
import '../../domain/repositories/inventory_device_repository.dart';
import '../datasources/firebase/firebase_inventory_device_datasource.dart';
import '../models/inventory_device_model.dart';

class InventoryDeviceRepositoryImpl implements InventoryDeviceRepository {
  InventoryDeviceRepositoryImpl(this._remote);

  final FirebaseInventoryDeviceDataSource _remote;

  @override
  Future<List<InventoryDeviceEntity>> getAll() async {
    try {
      return await _remote.getAll();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InventoryDeviceRepo] getAll failed: $e');
      }
      return [];
    }
  }

  @override
  Future<InventoryDeviceEntity?> getById(String id) async {
    try {
      return await _remote.getById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<InventoryDeviceEntity?> getByBarcode(String barcode) async {
    try {
      return await _remote.getByBarcode(barcode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> create(InventoryDeviceEntity entity) async {
    final model = InventoryDeviceModel.fromEntity(entity);
    await _remote.create(model);
  }

  @override
  Future<void> update(InventoryDeviceEntity entity) async {
    final model = InventoryDeviceModel.fromEntity(entity);
    await _remote.update(model);
  }

  @override
  Future<void> delete(String id) async {
    await _remote.delete(id);
  }
}
