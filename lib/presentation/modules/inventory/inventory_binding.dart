import 'package:get/get.dart';

import '../../../domain/usecases/category/get_categories.dart';
import '../../../domain/usecases/inventory/add_inventory_device.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/inventory/get_inventory_device_by_barcode.dart';
import 'inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryController>(
      () => InventoryController(
        Get.find<GetCategories>(),
        Get.find<AddInventoryDevice>(),
        Get.find<GetInventoryDevices>(),
        Get.find<GetInventoryDeviceByBarcode>(),
      ),
    );
  }
}
