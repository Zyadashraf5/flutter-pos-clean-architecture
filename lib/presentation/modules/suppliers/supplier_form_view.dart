import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/main_controller.dart';
import 'suppliers_controller.dart';

class SupplierFormView extends GetView<SuppliersController> {
  const SupplierFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    final isEdit = controller.editSupplierId.value != null;

    final existing = isEdit
        ? controller.suppliers
              .firstWhereOrNull(
                (s) => s.id == controller.editSupplierId.value,
              )
        : null;

    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit
            ? tr('edit_supplier', 'Edit Supplier')
            : tr('add_supplier', 'Add Supplier')),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.editSupplierId.value = null;
            Get.find<MainController>().goTo(AppRoutes.suppliers);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.md
              : AppSpacing.lg;
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: tr('supplier_name', 'Supplier Name'),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return tr('required_field', 'This field is required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: tr('phone', 'Phone'),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: padding),
                  Obx(() => ElevatedButton(
                        onPressed: controller.saving.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final ok = await controller.saveSupplier(
                                  id: controller.editSupplierId.value,
                                  name: nameController.text,
                                  phone: phoneController.text,
                                );
                                if (ok && context.mounted) {
                                  controller.editSupplierId.value = null;
                                  Get.find<MainController>()
                                      .goTo(AppRoutes.suppliers);
                                }
                              },
                        child: controller.saving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : Text(isEdit
                                ? tr('update', 'Update')
                                : tr('create', 'Create')),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
