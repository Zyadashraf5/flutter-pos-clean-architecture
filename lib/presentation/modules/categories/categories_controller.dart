import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/auth/permission.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/category/create_category.dart';
import '../../../domain/usecases/category/delete_category.dart';
import '../../../domain/usecases/category/get_categories.dart';
import '../../../domain/usecases/category/update_category.dart';
import '../../auth/auth_controller.dart';
import '../products/products_controller.dart';

class CategoriesController extends GetxController {
  CategoriesController(
    this._getCategories,
    this._createCategory,
    this._updateCategory,
    this._deleteCategory,
  );

  final GetCategories _getCategories;
  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  final categories = <CategoryEntity>[].obs;
  final loading = false.obs;
  final searchQuery = ''.obs;
  final editCategoryId = Rxn<String>();

  @override
  void onReady() {
    loadCategories();
    super.onReady();
  }

  Future<void> loadCategories() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageProducts)) return;
    loading.value = true;
    try {
      final list = await _getCategories();
      categories.assignAll(list);
      AppLogger.controller('Categories', 'loadCategories() assigned ${list.length} items');
    } catch (e) {
      AppLogger.controller('Categories', 'loadCategories() failed', e);
    } finally {
      loading.value = false;
    }
  }

  List<CategoryEntity> get filteredCategories {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return categories;
    return categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  Future<bool> saveCategory({String? id, required String name}) async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageProducts)) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    try {
      if (id != null && id.isNotEmpty) {
        await _updateCategory(CategoryEntity(id: id, name: trimmed));
      } else {
        await _createCategory(CategoryEntity(
          id: _generateId(),
          name: trimmed,
        ));
      }
      await loadCategories();
      _notifyProductsController();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteCategory(String id) async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageProducts)) return;
    await _deleteCategory(id);
    await loadCategories();
    _notifyProductsController();
  }

  void _notifyProductsController() {
    if (Get.isRegistered<ProductsController>()) {
      Get.find<ProductsController>().loadCategories();
    }
  }

  String _generateId() {
    return 'cat_${DateTime.now().millisecondsSinceEpoch}';
  }
}
