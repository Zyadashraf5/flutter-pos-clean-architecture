import '../../entities/inventory_device_entity.dart';
import '../../repositories/inventory_device_repository.dart';

class GetInventoryDevices {
  GetInventoryDevices(this._repository);

  final InventoryDeviceRepository _repository;

  Future<List<InventoryDeviceEntity>> call() => _repository.getAll();
}
