import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../layout/main_controller.dart';
import 'inventory_controller.dart';

class InventoryDeviceFormView extends GetView<InventoryController> {
  const InventoryDeviceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;

    // ── Text controllers ───────────────────────────────────────
    final deviceNameController = TextEditingController();
    final serial1Controller = TextEditingController();
    final serial2Controller = TextEditingController();
    final colorController = TextEditingController();
    final storageController = TextEditingController();
    final batteryHealthController = TextEditingController();
    final receivingPriceController = TextEditingController();
    final supplierNameController = TextEditingController();
    final supplierPhoneController = TextEditingController();
    final barcodeController = TextEditingController();

    // ── Reactive state ─────────────────────────────────────────
    final selectedCondition = Rxn<DeviceCondition>();
    final selectedPayment = Rxn<ReceivingPaymentMethod>();
    final selectedCategoryId = Rxn<String>();
    final generatingBarcode = false.obs;

    // ── Validation errors ──────────────────────────────────────
    final deviceNameError = ''.obs;
    final conditionError = ''.obs;
    final serial1Error = ''.obs;
    final serial2Error = ''.obs;
    final colorError = ''.obs;
    final storageError = ''.obs;
    final batteryError = ''.obs;
    final priceError = ''.obs;
    final paymentError = ''.obs;
    final supplierNameError = ''.obs;
    final supplierPhoneError = ''.obs;

    // Auto-generate barcode on load
    _generateBarcode(barcodeController, generatingBarcode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('add_device', 'Add Device')),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.find<MainController>().goTo(AppRoutes.inventory),
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
                // ─── Section: Device Name ─────────────────────────
                _SectionHeader(label: tr('device_name', 'Device Name')),
                const SizedBox(height: 8),
                Obx(
                  () => TextField(
                    controller: deviceNameController,
                    decoration: InputDecoration(
                      labelText: tr('device_name', 'Device Name'),
                      hintText: tr(
                        'device_name_hint',
                        'e.g. iPhone 14 Pro Max',
                      ),
                      errorText: deviceNameError.value.isEmpty
                          ? null
                          : deviceNameError.value,
                    ),
                    onChanged: (_) => deviceNameError.value = '',
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Section: Device Condition ────────────────────
                _SectionHeader(
                  label: tr('device_condition', 'Device Condition'),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ConditionCard(
                              label: tr('condition_used', 'Used'),
                              icon: Icons.phonelink_erase,
                              selected:
                                  selectedCondition.value ==
                                  DeviceCondition.used,
                              onTap: () {
                                selectedCondition.value = DeviceCondition.used;
                                conditionError.value = '';
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ConditionCard(
                              label: tr('condition_new', 'New'),
                              icon: Icons.phone_android,
                              selected:
                                  selectedCondition.value ==
                                  DeviceCondition.newDevice,
                              onTap: () {
                                selectedCondition.value =
                                    DeviceCondition.newDevice;
                                conditionError.value = '';
                              },
                            ),
                          ),
                        ],
                      ),
                      if (conditionError.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            conditionError.value,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Section: Barcode (auto-generated, read-only) ─
                _SectionHeader(label: tr('barcode', 'Barcode')),
                const SizedBox(height: 8),
                Obx(
                  () => TextField(
                    controller: barcodeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: tr('barcode', 'Barcode'),
                      hintText: tr('auto_generated_barcode', 'Auto-generated'),
                      suffixIcon: generatingBarcode.value
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.autorenew),
                              tooltip: tr('regenerate_barcode', 'Regenerate'),
                              onPressed: () => _generateBarcode(
                                barcodeController,
                                generatingBarcode,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Section: Serial Numbers ──────────────────────
                _SectionHeader(label: tr('serial_numbers', 'Serial Numbers')),
                const SizedBox(height: 8),
                if (isMobile) ...[
                  Obx(
                    () => TextField(
                      controller: serial1Controller,
                      decoration: InputDecoration(
                        labelText: tr('serial_number_1', 'Serial Number 1'),
                        errorText: serial1Error.value.isEmpty
                            ? null
                            : serial1Error.value,
                      ),
                      onChanged: (_) => serial1Error.value = '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => TextField(
                      controller: serial2Controller,
                      decoration: InputDecoration(
                        labelText: tr('serial_number_2', 'Serial Number 2'),
                        errorText: serial2Error.value.isEmpty
                            ? null
                            : serial2Error.value,
                      ),
                      onChanged: (_) => serial2Error.value = '',
                    ),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => TextField(
                            controller: serial1Controller,
                            decoration: InputDecoration(
                              labelText: tr(
                                'serial_number_1',
                                'Serial Number 1',
                              ),
                              errorText: serial1Error.value.isEmpty
                                  ? null
                                  : serial1Error.value,
                            ),
                            onChanged: (_) => serial1Error.value = '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => TextField(
                            controller: serial2Controller,
                            decoration: InputDecoration(
                              labelText: tr(
                                'serial_number_2',
                                'Serial Number 2',
                              ),
                              errorText: serial2Error.value.isEmpty
                                  ? null
                                  : serial2Error.value,
                            ),
                            onChanged: (_) => serial2Error.value = '',
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // ─── Section: Device Specifications ───────────────
                Obx(() {
                  final condition = selectedCondition.value;
                  if (condition == null) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tr(
                              'select_condition_first',
                              'Select device condition first to see specifications',
                            ),
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        label: tr('device_specs', 'Device Specifications'),
                      ),
                      const SizedBox(height: 8),
                      if (isMobile) ...[
                        Obx(
                          () => TextField(
                            controller: colorController,
                            decoration: InputDecoration(
                              labelText: tr('device_color', 'Color'),
                              errorText: colorError.value.isEmpty
                                  ? null
                                  : colorError.value,
                            ),
                            onChanged: (_) => colorError.value = '',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => TextField(
                            controller: storageController,
                            decoration: InputDecoration(
                              labelText: tr(
                                'device_storage',
                                'Storage (e.g. 128GB)',
                              ),
                              errorText: storageError.value.isEmpty
                                  ? null
                                  : storageError.value,
                            ),
                            onChanged: (_) => storageError.value = '',
                          ),
                        ),
                        if (condition == DeviceCondition.used) ...[
                          const SizedBox(height: 12),
                          Obx(
                            () => TextField(
                              controller: batteryHealthController,
                              decoration: InputDecoration(
                                labelText: tr(
                                  'battery_health',
                                  'Battery Health (e.g. 85%)',
                                ),
                                errorText: batteryError.value.isEmpty
                                    ? null
                                    : batteryError.value,
                              ),
                              onChanged: (_) => batteryError.value = '',
                            ),
                          ),
                        ],
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => TextField(
                                  controller: colorController,
                                  decoration: InputDecoration(
                                    labelText: tr('device_color', 'Color'),
                                    errorText: colorError.value.isEmpty
                                        ? null
                                        : colorError.value,
                                  ),
                                  onChanged: (_) => colorError.value = '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Obx(
                                () => TextField(
                                  controller: storageController,
                                  decoration: InputDecoration(
                                    labelText: tr(
                                      'device_storage',
                                      'Storage (e.g. 128GB)',
                                    ),
                                    errorText: storageError.value.isEmpty
                                        ? null
                                        : storageError.value,
                                  ),
                                  onChanged: (_) => storageError.value = '',
                                ),
                              ),
                            ),
                            if (condition == DeviceCondition.used) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: Obx(
                                  () => TextField(
                                    controller: batteryHealthController,
                                    decoration: InputDecoration(
                                      labelText: tr(
                                        'battery_health',
                                        'Battery Health (e.g. 85%)',
                                      ),
                                      errorText: batteryError.value.isEmpty
                                          ? null
                                          : batteryError.value,
                                    ),
                                    onChanged: (_) => batteryError.value = '',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // ─── Section: Receiving Price & Payment ────────────
                _SectionHeader(
                  label: tr('receiving_info', 'Receiving Information'),
                ),
                const SizedBox(height: 8),
                if (isMobile) ...[
                  Obx(
                    () => TextField(
                      controller: receivingPriceController,
                      decoration: InputDecoration(
                        labelText: tr('receiving_price', 'Receiving Price'),
                        errorText: priceError.value.isEmpty
                            ? null
                            : priceError.value,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (_) => priceError.value = '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<ReceivingPaymentMethod>(
                          initialValue: selectedPayment.value,
                          decoration: InputDecoration(
                            labelText: tr('payment_type', 'Payment Type'),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: ReceivingPaymentMethod.cash,
                              child: Text(tr('cash', 'Cash')),
                            ),
                            DropdownMenuItem(
                              value: ReceivingPaymentMethod.credit,
                              child: Text(
                                tr('credit_deferred', 'Credit (Deferred)'),
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReceivingPaymentMethod.bankTransfer,
                              child: Text(tr('bank_transfer', 'Bank Transfer')),
                            ),
                          ],
                          onChanged: (v) {
                            selectedPayment.value = v;
                            paymentError.value = '';
                          },
                        ),
                        if (paymentError.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              paymentError.value,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(
                          () => TextField(
                            controller: receivingPriceController,
                            decoration: InputDecoration(
                              labelText: tr(
                                'receiving_price',
                                'Receiving Price',
                              ),
                              errorText: priceError.value.isEmpty
                                  ? null
                                  : priceError.value,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.]'),
                              ),
                            ],
                            onChanged: (_) => priceError.value = '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<ReceivingPaymentMethod>(
                                initialValue: selectedPayment.value,
                                decoration: InputDecoration(
                                  labelText: tr('payment_type', 'Payment Type'),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: ReceivingPaymentMethod.cash,
                                    child: Text(tr('cash', 'Cash')),
                                  ),
                                  DropdownMenuItem(
                                    value: ReceivingPaymentMethod.credit,
                                    child: Text(
                                      tr(
                                        'credit_deferred',
                                        'Credit (Deferred)',
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: ReceivingPaymentMethod.bankTransfer,
                                    child: Text(
                                      tr('bank_transfer', 'Bank Transfer'),
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  selectedPayment.value = v;
                                  paymentError.value = '';
                                },
                              ),
                              if (paymentError.value.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    left: 4,
                                  ),
                                  child: Text(
                                    paymentError.value,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // ─── Section: Supplier ─────────────────────────────
                _SectionHeader(
                  label: tr('supplier_info', 'Supplier Information'),
                ),
                const SizedBox(height: 8),
                if (isMobile) ...[
                  Obx(
                    () => TextField(
                      controller: supplierNameController,
                      decoration: InputDecoration(
                        labelText: tr('supplier_name', 'Supplier Name'),
                        errorText: supplierNameError.value.isEmpty
                            ? null
                            : supplierNameError.value,
                      ),
                      onChanged: (_) => supplierNameError.value = '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => TextField(
                      controller: supplierPhoneController,
                      decoration: InputDecoration(
                        labelText: tr('supplier_phone', 'Supplier Phone'),
                        errorText: supplierPhoneError.value.isEmpty
                            ? null
                            : supplierPhoneError.value,
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => supplierPhoneError.value = '',
                    ),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => TextField(
                            controller: supplierNameController,
                            decoration: InputDecoration(
                              labelText: tr('supplier_name', 'Supplier Name'),
                              errorText: supplierNameError.value.isEmpty
                                  ? null
                                  : supplierNameError.value,
                            ),
                            onChanged: (_) => supplierNameError.value = '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => TextField(
                            controller: supplierPhoneController,
                            decoration: InputDecoration(
                              labelText: tr('supplier_phone', 'Supplier Phone'),
                              errorText: supplierPhoneError.value.isEmpty
                                  ? null
                                  : supplierPhoneError.value,
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => supplierPhoneError.value = '',
                          ),
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: padding),

                // ─── Section: Category ─────────────────────────────
                _SectionHeader(label: tr('category', 'Category')),
                const SizedBox(height: 8),
                Obx(() {
                  final cats = controller.categories;
                  if (cats.isEmpty) {
                    return Text(
                      tr('no_categories', 'No categories available'),
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: selectedCategoryId.value,
                    decoration: InputDecoration(
                      labelText: tr('category', 'Category'),
                      hintText: tr('select_category', 'Select Category'),
                    ),
                    items: cats
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => selectedCategoryId.value = v,
                  );
                }),

                SizedBox(height: padding),

                // ─── Submit Button ─────────────────────────────────
                Obx(
                  () => SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.savingDevice.value ||
                              generatingBarcode.value
                          ? null
                          : () => _handleSubmit(
                              context: context,
                              tr: tr,
                              deviceNameController: deviceNameController,
                              barcodeController: barcodeController,
                              serial1Controller: serial1Controller,
                              serial2Controller: serial2Controller,
                              colorController: colorController,
                              storageController: storageController,
                              batteryHealthController: batteryHealthController,
                              receivingPriceController:
                                  receivingPriceController,
                              supplierNameController: supplierNameController,
                              supplierPhoneController: supplierPhoneController,
                              selectedCondition: selectedCondition,
                              selectedPayment: selectedPayment,
                              selectedCategoryId: selectedCategoryId,
                              deviceNameError: deviceNameError,
                              conditionError: conditionError,
                              serial1Error: serial1Error,
                              serial2Error: serial2Error,
                              colorError: colorError,
                              storageError: storageError,
                              batteryError: batteryError,
                              priceError: priceError,
                              paymentError: paymentError,
                              supplierNameError: supplierNameError,
                              supplierPhoneError: supplierPhoneError,
                            ),
                      icon: controller.savingDevice.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(tr('add_device', 'Add Device')),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Barcode auto-generation ──────────────────────────────────

  Future<void> _generateBarcode(
    TextEditingController barcodeCtrl,
    RxBool generating,
  ) async {
    generating.value = true;
    try {
      final barcode = await controller.generateUniqueDeviceBarcode();
      barcodeCtrl.text = barcode;
    } finally {
      generating.value = false;
    }
  }

  // ── Validation & submission ──────────────────────────────────

  Future<void> _handleSubmit({
    required BuildContext context,
    required String Function(String, [String?]) tr,
    required TextEditingController deviceNameController,
    required TextEditingController barcodeController,
    required TextEditingController serial1Controller,
    required TextEditingController serial2Controller,
    required TextEditingController colorController,
    required TextEditingController storageController,
    required TextEditingController batteryHealthController,
    required TextEditingController receivingPriceController,
    required TextEditingController supplierNameController,
    required TextEditingController supplierPhoneController,
    required Rxn<DeviceCondition> selectedCondition,
    required Rxn<ReceivingPaymentMethod> selectedPayment,
    required Rxn<String> selectedCategoryId,
    required RxString deviceNameError,
    required RxString conditionError,
    required RxString serial1Error,
    required RxString serial2Error,
    required RxString colorError,
    required RxString storageError,
    required RxString batteryError,
    required RxString priceError,
    required RxString paymentError,
    required RxString supplierNameError,
    required RxString supplierPhoneError,
  }) async {
    bool hasError = false;

    // Device name
    if (deviceNameController.text.trim().isEmpty) {
      deviceNameError.value = tr(
        'device_name_required',
        'Device name is required',
      );
      hasError = true;
    }

    // Condition
    if (selectedCondition.value == null) {
      conditionError.value = tr(
        'condition_required',
        'Please select device condition',
      );
      hasError = true;
    }

    // Serial numbers
    if (serial1Controller.text.trim().isEmpty) {
      serial1Error.value = tr(
        'serial1_required',
        'Serial Number 1 is required',
      );
      hasError = true;
    }
    if (serial2Controller.text.trim().isEmpty) {
      serial2Error.value = tr(
        'serial2_required',
        'Serial Number 2 is required',
      );
      hasError = true;
    }

    // Color
    if (colorController.text.trim().isEmpty) {
      colorError.value = tr('color_required', 'Color is required');
      hasError = true;
    }

    // Storage
    if (storageController.text.trim().isEmpty) {
      storageError.value = tr('storage_required', 'Storage is required');
      hasError = true;
    }

    // Battery health (only for used)
    if (selectedCondition.value == DeviceCondition.used &&
        batteryHealthController.text.trim().isEmpty) {
      batteryError.value = tr(
        'battery_required',
        'Battery health is required for used devices',
      );
      hasError = true;
    }

    // Receiving price
    final price = double.tryParse(receivingPriceController.text.trim());
    if (price == null || price <= 0) {
      priceError.value = tr('price_required', 'Enter a valid receiving price');
      hasError = true;
    }

    // Payment type
    if (selectedPayment.value == null) {
      paymentError.value = tr('payment_required', 'Please select payment type');
      hasError = true;
    }

    // Supplier name
    if (supplierNameController.text.trim().isEmpty) {
      supplierNameError.value = tr(
        'supplier_name_required',
        'Supplier name is required',
      );
      hasError = true;
    }

    // Supplier phone
    final phone = supplierPhoneController.text.trim();
    if (phone.isEmpty) {
      supplierPhoneError.value = tr(
        'supplier_phone_required',
        'Supplier phone is required',
      );
      hasError = true;
    } else if (!_isValidPhone(phone)) {
      supplierPhoneError.value = tr(
        'invalid_phone',
        'Invalid phone number format',
      );
      hasError = true;
    }

    if (hasError) return;

    // Build entity
    final device = InventoryDeviceEntity(
      id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
      deviceName: deviceNameController.text.trim(),
      barcode: barcodeController.text.trim(),
      serialNumber1: serial1Controller.text.trim(),
      serialNumber2: serial2Controller.text.trim(),
      condition: selectedCondition.value!,
      color: colorController.text.trim(),
      storage: storageController.text.trim(),
      batteryHealth: selectedCondition.value == DeviceCondition.used
          ? batteryHealthController.text.trim()
          : null,
      receivingPrice: price!,
      paymentMethod: selectedPayment.value!,
      supplierName: supplierNameController.text.trim(),
      supplierPhone: phone,
      categoryId: selectedCategoryId.value,
      createdAt: DateTime.now(),
    );

    final ok = await controller.saveDevice(device);
    if (ok) {
      Get.find<MainController>().goTo(AppRoutes.inventory);
    }
  }

  /// Basic phone validation: at least 7 digits, may start with +
  bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned);
  }
}

// ═════════════════════════════════════════════════════════════════
//  Reusable UI components
// ═════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.onSurfaceVariant.withValues(alpha: 0.25),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
