import 'dart:convert';
import 'dart:io' show Directory, File;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/inventory_device_entity.dart';

// Legacy backward-compatible imports (products module is dead code, routes
// redirect to inventory). These keep the old call-sites compiling.
// ignore: unused_import
import '../../domain/entities/product_entity.dart';

String buildDeviceQrData(InventoryDeviceEntity device) {
  return jsonEncode({
    'deviceId': device.id,
    'deviceName': device.deviceName,
    'barcode': device.barcode,
    'serialNumber1': device.serialNumber1,
    'serialNumber2': device.serialNumber2,
    'condition': device.condition,
    'color': device.color,
    'storage': device.storage,
    'batteryHealth': device.batteryHealth,
    'receivingPrice': device.receivingPrice,
    'sellingPrice': device.sellingPrice,
    'categoryId': device.categoryId,
    'isSold': device.isSold,
    'createdAt':
        device.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
  });
}

String buildDeviceQrDataFromForm({
  required String deviceId,
  required String deviceName,
  required String barcode,
  required String serialNumber1,
  required String serialNumber2,
  required String condition,
  required String color,
  required String storage,
  required double receivingPrice,
  required String categoryId,
}) {
  return jsonEncode({
    'deviceId': deviceId,
    'deviceName': deviceName,
    'barcode': barcode,
    'serialNumber1': serialNumber1,
    'serialNumber2': serialNumber2,
    'condition': condition,
    'color': color,
    'storage': storage,
    'receivingPrice': receivingPrice,
    'categoryId': categoryId,
    'createdAt': DateTime.now().toIso8601String(),
  });
}

void showQrDeviceDialog(BuildContext context, InventoryDeviceEntity device) {
  final qrData = buildDeviceQrData(device);
  _showQrDialog(context, qrData, device.deviceName);
}

// ── Legacy stubs (products module is dead code) ────────────────
@Deprecated('Use buildDeviceQrDataFromForm instead')
String buildProductQrDataFromForm({
  required String productId,
  required String name,
  required String barcode,
  required double sellingPrice,
  required double purchasePrice,
  required String categoryId,
  required int quantity,
  required double taxPercent,
}) {
  return jsonEncode({
    'productId': productId,
    'name': name,
    'barcode': barcode,
    'sellingPrice': sellingPrice,
    'purchasePrice': purchasePrice,
    'category': categoryId,
    'quantity': quantity,
    'taxPercent': taxPercent,
    'createdAt': DateTime.now().toIso8601String(),
  });
}

@Deprecated('Use showQrDeviceDialog instead')
void showQrProductDialog(BuildContext context, ProductEntity product) {
  final qrData = jsonEncode({
    'productId': product.id,
    'name': product.name,
    'barcode': product.barcode,
    'sellingPrice': product.sellingPrice,
    'purchasePrice': product.purchasePrice,
    'category': product.categoryId,
    'quantity': product.quantity,
    'taxPercent': product.taxPercent,
    'createdAt':
        product.createdAt?.toIso8601String() ??
        DateTime.now().toIso8601String(),
  });
  _showQrDialog(context, qrData, product.name);
}

void showQrFromData(BuildContext context, String qrData, String title) {
  _showQrDialog(context, qrData, title);
}

void _showQrDialog(BuildContext context, String qrData, String title) {
  final qrKey = GlobalKey();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  gapless: true,
                  errorStateBuilder: (_, __) =>
                      const Center(child: Text('QR Error')),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.copy,
                  label: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: qrData));
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('QR data copied')),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.download,
                  label: 'Save',
                  onPressed: () => _saveQrImage(ctx, qrKey),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _saveQrImage(BuildContext context, GlobalKey qrKey) async {
  try {
    final boundary =
        qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();

    final dir = Directory.systemTemp;
    final fileName = 'qr_product_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pngBytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR saved to: ${file.path}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
