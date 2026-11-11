import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/locale_format.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import 'qr_scanner_controller.dart';

class QrScannerView extends GetView<QrScannerController> {
  const QrScannerView({super.key});

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
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('qr_scanner', 'QR Scanner')),
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.scannedData.value != null) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: tr('scan_again', 'Scan Again'),
                onPressed: () {
                  controller.reset();
                  textController.clear();
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < AppSpacing.breakpointCompact
              ? AppSpacing.md
              : AppSpacing.lg;
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Obx(() {
              if (controller.scannedData.value == null) {
                return _buildScanInput(context, textController, tr);
              }
              if (controller.loading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildResult(context, tr);
            }),
          );
        },
      ),
    );
  }

  Widget _buildScanInput(
    BuildContext context,
    TextEditingController textController,
    String Function(String, [String?]) tr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isMobilePlatform) ...[
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final code = barcodes.first.rawValue;
                    if (code != null && code.isNotEmpty) {
                      controller.handleScannedData(code);
                    }
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tr('or_paste_qr', 'Or paste QR data below:'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ] else ...[
          const Icon(
            Icons.qr_code_scanner_rounded,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            tr('paste_qr_data', 'Paste QR data or enter barcode below'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
        ],
        TextField(
          controller: textController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: tr('qr_data', 'QR Data / Barcode'),
            hintText: tr(
              'paste_json_hint',
              'Paste QR data or enter barcode number...',
            ),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.paste),
              tooltip: tr('paste', 'Paste'),
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null && data!.text!.isNotEmpty) {
                  textController.text = data.text!;
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => controller.handleTextInput(textController.text),
          icon: const Icon(Icons.search),
          label: Text(tr('decode', 'Decode')),
        ),
      ],
    );
  }

  Widget _buildResult(
    BuildContext context,
    String Function(String, [String?]) tr,
  ) {
    final json = controller.decodedJson.value;
    final device = controller.liveDevice.value;
    final error = controller.errorMessage.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error.isNotEmpty) ...[
          _ErrorCard(message: error),
          const SizedBox(height: 16),
          _RawDataCard(data: controller.scannedData.value ?? '', tr: tr),
        ] else if (device != null) ...[
          _SectionHeader(title: tr('live_device', 'Device Data')),
          const SizedBox(height: 8),
          _DeviceDetailCard(device: device, tr: tr, context: context),
        ] else if (json != null) ...[
          _SectionHeader(title: tr('qr_decoded', 'QR Decoded Data')),
          const SizedBox(height: 8),
          _JsonDetailCard(json: json, tr: tr),
          const SizedBox(height: 12),
          Text(
            tr('device_not_found_qr', 'Device not found in database'),
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ] else ...[
          _RawDataCard(data: controller.scannedData.value ?? '', tr: tr),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _DeviceDetailCard extends StatelessWidget {
  const _DeviceDetailCard({
    required this.device,
    required this.tr,
    required this.context,
  });

  final InventoryDeviceEntity device;
  final String Function(String, [String?]) tr;
  final BuildContext context;

  @override
  Widget build(BuildContext innerContext) {
    final conditionLabel = device.condition == DeviceCondition.used
        ? tr('condition_used', 'Used')
        : tr('condition_new', 'New');
    final soldLabel = device.isSold
        ? tr('sold', 'Sold')
        : tr('available', 'Available');
    final soldColor = device.isSold ? AppColors.error : Colors.green;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.deviceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: soldColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    soldLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: soldColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _Row(label: tr('barcode'), value: device.barcode),
            _Row(
              label: tr('serial_number_1', 'S/N 1'),
              value: device.serialNumber1,
            ),
            _Row(
              label: tr('serial_number_2', 'S/N 2'),
              value: device.serialNumber2,
            ),
            _Row(
              label: tr('device_condition', 'Condition'),
              value: conditionLabel,
            ),
            _Row(label: tr('device_color', 'Color'), value: device.color),
            _Row(label: tr('device_storage', 'Storage'), value: device.storage),
            if (device.batteryHealth != null &&
                device.batteryHealth!.isNotEmpty)
              _Row(
                label: tr('battery_health', 'Battery'),
                value: device.batteryHealth!,
              ),
            _Row(
              label: tr('receiving_price', 'Receiving Price'),
              value: LocaleFormat.currency(device.receivingPrice, context),
            ),
            if (device.sellingPrice != null)
              _Row(
                label: tr('selling_price', 'Selling Price'),
                value: LocaleFormat.currency(device.sellingPrice!, context),
              ),
            _Row(
              label: tr('supplier_name', 'Supplier'),
              value: device.supplierName,
            ),
            if (device.createdAt != null)
              _Row(
                label: tr('created_at', 'Created'),
                value: _formatDate(device.createdAt!),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _JsonDetailCard extends StatelessWidget {
  const _JsonDetailCard({required this.json, required this.tr});

  final Map<String, dynamic> json;
  final String Function(String, [String?]) tr;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: json.entries
              .map((e) => _Row(label: e.key, value: e.value?.toString() ?? '-'))
              .toList(),
        ),
      ),
    );
  }
}

class _RawDataCard extends StatelessWidget {
  const _RawDataCard({required this.data, required this.tr});

  final String data;
  final String Function(String, [String?]) tr;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('raw_data', 'Raw Data'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              data,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: data));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('copied', 'Copied to clipboard'))),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(tr('copy', 'Copy')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.error.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
