import 'package:get/get.dart';

import '../../../domain/usecases/category/create_category.dart';
import '../../../domain/usecases/category/delete_category.dart';
import '../../../domain/usecases/category/get_categories.dart';
import '../../../domain/usecases/category/update_category.dart';
import 'categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesController>(
      () => CategoriesController(
        Get.find<GetCategories>(),
        Get.find<CreateCategory>(),
        Get.find<UpdateCategory>(),
        Get.find<DeleteCategory>(),
      ),
    );
  }
}
