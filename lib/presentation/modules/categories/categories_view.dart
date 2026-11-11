import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../layout/main_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_card.dart';
import 'categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('categories')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.find<MainController>().goTo(AppRoutes.categoryForm);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.sm
              : AppSpacing.md;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: tr('search_categories'),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (v) => controller.searchQuery.value = v,
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.loading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            tr('loading'),
                            style: const TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }
                  final list = controller.filteredCategories;
                  if (list.isEmpty) {
                    return EmptyState(
                      message: tr('no_categories'),
                      icon: Icons.category_outlined,
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final c = list[i];
                      return ItemCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {
                                Get.find<MainController>().goTo(AppRoutes.categoryForm);
                                controller.editCategoryId.value = c.id;
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(controller, c, tr),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(CategoriesController ctrl, CategoryEntity c, String Function(String key, [String? fallback]) tr) {
    Get.dialog(
      AlertDialog(
        title: Text(tr('delete')),
        content: Text(tr('delete_category_confirm')),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.deleteCategory(c.id);
            },
            child: Text(tr('delete'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
