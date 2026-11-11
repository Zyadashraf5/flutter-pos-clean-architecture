import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/product_entity.dart';
import '../../layout/main_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/qr_product_dialog.dart';
import 'products_controller.dart';

class ProductFormView extends GetView<ProductsController> {
  const ProductFormView({super.key});

  static bool get _isMobilePlatform {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    final isEdit = controller.editProductId.value != null;
    ProductEntity? existing;
    if (isEdit) {
      try {
        existing = controller.products.firstWhere(
          (p) => p.id == controller.editProductId.value,
        );
      } catch (_) {
        existing = null;
      }
    }

    final nameController = TextEditingController(text: existing?.name ?? '');
    final purchaseController = TextEditingController(
      text: existing?.purchasePrice.toString() ?? '0',
    );
    final sellingController = TextEditingController(
      text: existing?.sellingPrice.toString() ?? '0',
    );
    final quantityController = TextEditingController(
      text: existing?.quantity.toString() ?? '0',
    );
    final taxController = TextEditingController(
      text: existing?.taxPercent.toString() ?? '0',
    );
    final barcodeController = TextEditingController(
      text: existing?.barcode ?? '',
    );

    final barcodeError = ''.obs;
    final barcodeValidating = false.obs;
    final generatingBarcode = false.obs;
    final savedQrData = Rxn<String>();
    final qrKey = GlobalKey();

    if (!isEdit && barcodeController.text.isEmpty) {
      _autoGenerateBarcode(
        barcodeController,
        generatingBarcode,
        barcodeError,
      );
    }

    Future<void> validateBarcode(String barcode) async {
      if (barcode.trim().isEmpty) {
        barcodeError.value = '';
        return;
      }
      barcodeValidating.value = true;
      try {
        final unique = await controller.isBarcodeUnique(
          barcode,
          excludeProductId: controller.editProductId.value,
        );
        barcodeError.value = unique
            ? ''
            : tr('barcode_duplicate', 'This barcode is already in use');
      } finally {
        barcodeValidating.value = false;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? tr('edit_product') : tr('new_product')),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.editProductId.value = null;
            Get.find<MainController>().goTo(AppRoutes.products);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.md
              : AppSpacing.lg;
          final isMobile = constraints.maxWidth < AppSpacing.breakpointMobile;
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: tr('product_name')),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final value =
                      controller.formCategoryId.value ??
                      existing?.categoryId ??
                      (controller.categories.isNotEmpty
                          ? controller.categories.first.id
                          : null);
                  return DropdownButtonFormField<String>(
                    value: value,
                    decoration: InputDecoration(labelText: tr('category')),
                    items: controller.categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => controller.formCategoryId.value = v,
                  );
                }),
                const SizedBox(height: 16),
                Obx(() => TextField(
                      controller: barcodeController,
                      decoration: InputDecoration(
                        labelText: tr('barcode_serial'),
                        hintText: tr('scan_or_enter'),
                        errorText: barcodeError.value.isEmpty
                            ? null
                            : barcodeError.value,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (barcodeValidating.value ||
                                generatingBarcode.value)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.autorenew),
                              tooltip: tr(
                                'generate_barcode',
                                'Generate Barcode',
                              ),
                              onPressed: generatingBarcode.value
                                  ? null
                                  : () => _autoGenerateBarcode(
                                        barcodeController,
                                        generatingBarcode,
                                        barcodeError,
                                      ),
                            ),
                            if (_isMobilePlatform)
                              IconButton(
                                icon: const Icon(Icons.qr_code_scanner),
                                tooltip: tr('scan_barcode', 'Scan Barcode'),
                                onPressed: () => _openBarcodeScanner(
                                  context,
                                  barcodeController,
                                  validateBarcode,
                                  tr,
                                ),
                              ),
                          ],
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (v) => validateBarcode(v),
                    )),
                const SizedBox(height: 16),
                if (isMobile) ...[
                  TextField(
                    controller: purchaseController,
                    decoration: InputDecoration(
                      labelText: tr('purchase_price'),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sellingController,
                    decoration: InputDecoration(labelText: tr('selling_price')),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: purchaseController,
                          decoration: InputDecoration(
                            labelText: tr('purchase_price'),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: sellingController,
                          decoration: InputDecoration(
                            labelText: tr('selling_price'),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (isMobile) ...[
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: tr('quantity')),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: taxController,
                    decoration: InputDecoration(labelText: tr('tax_percent')),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: tr('quantity'),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: taxController,
                          decoration: InputDecoration(
                            labelText: tr('tax_percent'),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: padding),
                Obx(() => ElevatedButton(
                      onPressed: barcodeError.value.isNotEmpty ||
                              barcodeValidating.value ||
                              generatingBarcode.value
                          ? null
                          : () async {
                              final categoryId =
                                  controller.formCategoryId.value ??
                                  existing?.categoryId ??
                                  (controller.categories.isNotEmpty
                                      ? controller.categories.first.id
                                      : '');
                              if (categoryId.isEmpty) {
                                Get.snackbar(
                                    tr('error'), tr('add_category_first'));
                                return;
                              }
                              final barcode = barcodeController.text.trim();
                              if (barcode.isNotEmpty) {
                                final unique =
                                    await controller.isBarcodeUnique(
                                  barcode,
                                  excludeProductId:
                                      controller.editProductId.value,
                                );
                                if (!unique) {
                                  barcodeError.value = tr('barcode_duplicate',
                                      'This barcode is already in use');
                                  return;
                                }
                              }

                              final productId =
                                  controller.editProductId.value ??
                                  'prod_${DateTime.now().millisecondsSinceEpoch}';

                              final ok = await controller.saveProduct(
                                id: controller.editProductId.value,
                                name: nameController.text,
                                categoryId: categoryId,
                                purchasePrice:
                                    double.tryParse(purchaseController.text) ??
                                        0,
                                sellingPrice:
                                    double.tryParse(sellingController.text) ?? 0,
                                quantity:
                                    int.tryParse(quantityController.text) ?? 0,
                                taxPercent:
                                    double.tryParse(taxController.text) ?? 0,
                                barcode: barcode,
                              );
                              if (ok) {
                                savedQrData.value =
                                    buildProductQrDataFromForm(
                                  productId: productId,
                                  name: nameController.text.trim(),
                                  barcode: barcode,
                                  sellingPrice:
                                      double.tryParse(sellingController.text) ??
                                          0,
                                  purchasePrice:
                                      double.tryParse(
                                          purchaseController.text) ??
                                      0,
                                  categoryId: categoryId,
                                  quantity:
                                      int.tryParse(quantityController.text) ??
                                          0,
                                  taxPercent:
                                      double.tryParse(taxController.text) ?? 0,
                                );
                                controller.editProductId.value = null;
                              }
                            },
                      child: Text(isEdit ? tr('update') : tr('create')),
                    )),
                const SizedBox(height: 24),
                Obx(() {
                  final qrData = savedQrData.value;
                  if (qrData == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      RepaintBoundary(
                        key: qrKey,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 160,
                                gapless: true,
                                errorStateBuilder: (_, __) => const Center(
                                  child: Text('QR Error'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                barcodeController.text.trim(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                controller.downloadQrFromBoundary(qrKey),
                            icon: const Icon(Icons.download, size: 18),
                            label: Text(
                              tr('download', 'Download'),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: qrData),
                              );
                              Get.snackbar(
                                tr('copied', 'Copied'),
                                tr('qr_data_copied',
                                    'QR data copied to clipboard'),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: Text(tr('copy', 'Copy')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          savedQrData.value = null;
                          Get.find<MainController>()
                              .goTo(AppRoutes.products);
                        },
                        child: Text(
                          tr('go_to_products', 'Go to Products'),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _autoGenerateBarcode(
    TextEditingController barcodeController,
    RxBool generating,
    RxString error,
  ) async {
    generating.value = true;
    try {
      final barcode = await controller.generateUniqueBarcode();
      barcodeController.text = barcode;
      error.value = '';
    } finally {
      generating.value = false;
    }
  }

  void _openBarcodeScanner(
    BuildContext context,
    TextEditingController barcodeController,
    Future<void> Function(String) onScanned,
    String Function(String, [String?]) tr,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    tr('scan_barcode', 'Scan Barcode'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final code = barcodes.first.rawValue;
                    if (code != null && code.isNotEmpty) {
                      barcodeController.text = code;
                      Navigator.of(ctx).pop();
                      onScanned(code);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
