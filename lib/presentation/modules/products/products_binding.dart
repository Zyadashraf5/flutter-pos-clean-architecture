import 'package:get/get.dart';

import '../../../domain/usecases/category/get_categories.dart';
import '../../../domain/usecases/order/get_orders.dart';
import '../../../domain/usecases/product/create_product.dart';
import '../../../domain/usecases/product/delete_product.dart';
import '../../../domain/usecases/product/get_product_by_barcode.dart';
import '../../../domain/usecases/product/get_products.dart';
import '../../../domain/usecases/product/update_product.dart';
import 'products_controller.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsController>(
      () => ProductsController(
        Get.find<GetProducts>(),
        Get.find<GetCategories>(),
        Get.find<CreateProduct>(),
        Get.find<UpdateProduct>(),
        Get.find<DeleteProduct>(),
        Get.find<GetOrders>(),
        Get.find<GetProductByBarcode>(),
      ),
    );
  }
}
