import 'package:get/get.dart';

import '../../../domain/usecases/inventory/get_inventory_device_by_barcode.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import 'qr_scanner_controller.dart';

class QrScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrScannerController>(
      () => QrScannerController(
        Get.find<GetInventoryDevices>(),
        Get.find<GetInventoryDeviceByBarcode>(),
      ),
    );
  }
}
