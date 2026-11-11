import 'package:get/get.dart';

import '../../../domain/usecases/inventory/get_inventory_device_by_barcode.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/order/create_order.dart';
import '../../../domain/usecases/order/delete_order.dart';
import '../../../domain/usecases/order/get_orders.dart';
import '../../../domain/usecases/settings/get_default_tax.dart';
import 'orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(
      () => OrdersController(
        Get.find<GetOrders>(),
        Get.find<GetInventoryDeviceByBarcode>(),
        Get.find<GetInventoryDevices>(),
        Get.find<GetDefaultTax>(),
        Get.find<CreateOrder>(),
        Get.find<DeleteOrder>(),
      ),
    );
  }
}
