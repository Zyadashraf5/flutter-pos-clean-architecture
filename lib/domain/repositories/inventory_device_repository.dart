import '../entities/inventory_device_entity.dart';

abstract class InventoryDeviceRepository {
  Future<List<InventoryDeviceEntity>> getAll();
  Future<InventoryDeviceEntity?> getById(String id);
  Future<InventoryDeviceEntity?> getByBarcode(String barcode);
  Future<void> create(InventoryDeviceEntity entity);
  Future<void> update(InventoryDeviceEntity entity);
  Future<void> delete(String id);
}
