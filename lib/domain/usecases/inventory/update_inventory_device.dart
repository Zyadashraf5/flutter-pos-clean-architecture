import '../../entities/inventory_device_entity.dart';
import '../../repositories/inventory_device_repository.dart';

class UpdateInventoryDevice {
  UpdateInventoryDevice(this._repository);

  final InventoryDeviceRepository _repository;

  Future<void> call(InventoryDeviceEntity entity) => _repository.update(entity);
}
