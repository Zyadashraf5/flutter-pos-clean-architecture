import 'package:get/get.dart';

import '../../../domain/repositories/financial_repository.dart';
import '../../../domain/usecases/financial/get_financial_summary.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../../domain/usecases/order/get_orders.dart';
import '../../../domain/usecases/settings/get_default_tax.dart';
import '../../../domain/usecases/settings/set_default_tax.dart';
import 'financial_controller.dart';

class FinancialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinancialController>(
      () => FinancialController(
        Get.find<FinancialRepository>(),
        Get.find<GetFinancialSummary>(),
        Get.find<GetOrders>(),
        Get.find<GetInventoryDevices>(),
        Get.find<GetDefaultTax>(),
        Get.find<SetDefaultTax>(),
      ),
    );
  }
}
