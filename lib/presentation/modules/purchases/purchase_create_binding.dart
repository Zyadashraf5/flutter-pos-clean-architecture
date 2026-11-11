import 'package:get/get.dart';

import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/purchase/create_purchase.dart';
import '../../../domain/usecases/supplier/create_supplier.dart';
import '../../../domain/usecases/supplier/get_suppliers.dart';
import 'purchase_create_controller.dart';

class PurchaseCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchaseCreateController>(
      () => PurchaseCreateController(
        Get.find<GetSuppliers>(),
        Get.find<GetInventoryDevices>(),
        Get.find<CreateSupplier>(),
        Get.find<CreatePurchase>(),
      ),
    );
  }
}
