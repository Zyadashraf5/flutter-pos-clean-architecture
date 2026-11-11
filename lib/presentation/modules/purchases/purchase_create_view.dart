import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../../domain/entities/purchase_entity.dart' show PurchaseType;
import '../../layout/main_controller.dart';
import '../../widgets/item_card.dart';
import '../../../core/routes/app_routes.dart';
import 'purchase_create_controller.dart';

class PurchaseCreateView extends GetView<PurchaseCreateController> {
  const PurchaseCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    final padding =
        MediaQuery.sizeOf(context).width < AppSpacing.breakpointCompact
        ? AppSpacing.sm
        : AppSpacing.md;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Purchase'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.find<MainController>().goTo(AppRoutes.inventory),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, outerConstraints) {
          final isMobile =
              outerConstraints.maxWidth < AppSpacing.breakpointMobile;
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final children = <Widget>[
                    SizedBox(
                      width: isMobile ? double.infinity : 200,
                      child: DropdownButton<String?>(
                        value: controller.selectedSupplierId.value,
                        hint: const Text('Supplier'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('New supplier...'),
                          ),
                          ...controller.suppliers.map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          controller.selectedSupplierId.value = v;
                          if (v != null) controller.newSupplierName.value = '';
                        },
                      ),
                    ),
                    if (controller.selectedSupplierId.value == null) ...[
                      SizedBox(
                        width: isMobile ? 0 : 12,
                        height: isMobile ? 8 : 0,
                      ),
                      SizedBox(
                        width: isMobile ? double.infinity : 180,
                        child: TextField(
                          onChanged: (v) =>
                              controller.newSupplierName.value = v,
                          decoration: const InputDecoration(
                            labelText: 'Supplier name',
                          ),
                        ),
                      ),
                    ],
                  ];
                  return isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: children,
                        )
                      : Row(children: children);
                }),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text(tr('cash')),
                        selected:
                            controller.purchaseType.value == PurchaseType.cash,
                        onSelected: (_) =>
                            controller.purchaseType.value = PurchaseType.cash,
                      ),
                      ChoiceChip(
                        label: Text(tr('credit')),
                        selected:
                            controller.purchaseType.value ==
                            PurchaseType.credit,
                        onSelected: (_) =>
                            controller.purchaseType.value = PurchaseType.credit,
                      ),
                      if (controller.purchaseType.value == PurchaseType.credit)
                        SizedBox(
                          width: 100,
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Paid',
                            ),
                            onChanged: (v) => controller.paidAmount.value =
                                double.tryParse(v) ?? 0,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () => controller.addLine(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add line'),
                    ),
                  ],
                ),
                Obx(
                  () => Column(
                    children: List.generate(controller.lines.length, (i) {
                      final line = controller.lines[i];
                      if (isMobile) {
                        return ItemCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton<String>(
                                value: line.productId,
                                hint: const Text('Device'),
                                isExpanded: true,
                                items: controller.devices
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p.id,
                                        child: Text(p.deviceName),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  line.productId = v;
                                  line.productName = controller.devices
                                      .where((x) => x.id == v)
                                      .firstOrNull
                                      ?.deviceName;
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Qty',
                                      ),
                                      onChanged: (v) {
                                        line.quantity = int.tryParse(v) ?? 0;
                                        controller.lines.refresh();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        labelText: 'Price',
                                      ),
                                      onChanged: (v) {
                                        line.purchasePrice =
                                            double.tryParse(v) ?? 0;
                                        controller.lines.refresh();
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () => controller.removeLine(i),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return ItemCard(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButton<String>(
                                value: line.productId,
                                hint: const Text('Device'),
                                isExpanded: true,
                                items: controller.devices
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p.id,
                                        child: Text(p.deviceName),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  line.productId = v;
                                  line.productName = controller.devices
                                      .where((x) => x.id == v)
                                      .firstOrNull
                                      ?.deviceName;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                ),
                                onChanged: (v) {
                                  line.quantity = int.tryParse(v) ?? 0;
                                  controller.lines.refresh();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: TextField(
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                ),
                                onChanged: (v) {
                                  line.purchasePrice = double.tryParse(v) ?? 0;
                                  controller.lines.refresh();
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => controller.removeLine(i),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Total: ${LocaleFormat.currency(controller.totalAmount, context)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton(
                        onPressed: controller.submitting.value
                            ? null
                            : () async {
                                final ok = await controller.submit();
                                if (ok) {
                                  Get.snackbar('Purchase', 'Created');
                                  Get.find<MainController>().goTo(
                                    AppRoutes.inventory,
                                  );
                                }
                              },
                        child: controller.submitting.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Purchase'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
