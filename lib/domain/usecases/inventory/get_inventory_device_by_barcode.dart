import '../../entities/inventory_device_entity.dart';
import '../../repositories/inventory_device_repository.dart';

class GetInventoryDeviceByBarcode {
  GetInventoryDeviceByBarcode(this._repository);

  final InventoryDeviceRepository _repository;

  Future<InventoryDeviceEntity?> call(String barcode) =>
      _repository.getByBarcode(barcode);
}
