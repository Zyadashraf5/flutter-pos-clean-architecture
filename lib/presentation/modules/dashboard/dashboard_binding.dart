import 'package:get/get.dart';

import '../../../domain/usecases/financial/get_financial_summary.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/order/get_orders.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        Get.find<GetFinancialSummary>(),
        Get.find<GetOrders>(),
        Get.find<GetInventoryDevices>(),
      ),
    );
  }
}
