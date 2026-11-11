import 'package:get/get.dart';

import '../../../domain/usecases/purchase/get_purchases.dart';
import '../../../domain/usecases/supplier/create_supplier.dart';
import '../../../domain/usecases/supplier/delete_supplier.dart';
import '../../../domain/usecases/supplier/get_suppliers.dart';
import '../../../domain/usecases/supplier/record_supplier_payment.dart';
import '../../../domain/usecases/supplier/update_supplier.dart';
import 'suppliers_controller.dart';

class SuppliersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuppliersController>(
      () => SuppliersController(
        Get.find<GetSuppliers>(),
        Get.find<RecordSupplierPayment>(),
        Get.find<GetPurchases>(),
        Get.find<DeleteSupplier>(),
        Get.find<CreateSupplier>(),
        Get.find<UpdateSupplier>(),
      ),
    );
  }
}
