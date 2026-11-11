import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../layout/main_controller.dart';
import '../../../core/routes/app_routes.dart';
import 'categories_controller.dart';

class CategoryFormView extends GetView<CategoriesController> {
  const CategoryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    final isEdit = controller.editCategoryId.value != null;
    CategoryEntity? existing;
    if (isEdit) {
      try {
        existing = controller.categories.firstWhere(
          (c) => c.id == controller.editCategoryId.value,
        );
      } catch (_) {
        existing = null;
      }
    }
    final nameController = TextEditingController(text: existing?.name ?? '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? tr('edit_category') : tr('new_category')),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.editCategoryId.value = null;
            Get.find<MainController>().goTo(AppRoutes.categories);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.md
              : AppSpacing.lg;
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: tr('category_name'),
                    hintText: tr('enter_name'),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: padding),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await controller.saveCategory(
                      id: controller.editCategoryId.value,
                      name: nameController.text,
                    );
                    if (ok && context.mounted) {
                      controller.editCategoryId.value = null;
                      Get.find<MainController>().goTo(AppRoutes.categories);
                    }
                  },
                  child: Text(isEdit ? tr('update') : tr('create')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
