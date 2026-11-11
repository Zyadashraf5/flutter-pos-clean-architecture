import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/inventory_device_entity.dart';
import '../../../domain/usecases/inventory/get_inventory_device_by_barcode.dart';
import '../../../domain/usecases/inventory/get_inventory_devices.dart';

class QrScannerController extends GetxController {
  QrScannerController(this._getDevices, this._getDeviceByBarcode);

  final GetInventoryDevices _getDevices;
  final GetInventoryDeviceByBarcode _getDeviceByBarcode;

  final scanning = false.obs;
  final loading = false.obs;
  final scannedData = Rxn<String>();
  final decodedJson = Rxn<Map<String, dynamic>>();
  final liveDevice = Rxn<InventoryDeviceEntity>();
  final errorMessage = ''.obs;

  Future<void> handleScannedData(String rawData) async {
    if (loading.value) return;
    scannedData.value = rawData;
    decodedJson.value = null;
    liveDevice.value = null;
    errorMessage.value = '';
    loading.value = true;

    try {
      final Map<String, dynamic> json = jsonDecode(rawData);
      decodedJson.value = json;

      final deviceId = json['deviceId'] as String?;
      final barcode = json['barcode'] as String?;
      if (barcode != null && barcode.isNotEmpty) {
        await _lookupByBarcode(barcode);
      } else if (deviceId != null && deviceId.isNotEmpty) {
        await _fetchLiveDevice(deviceId);
      }
    } on FormatException {
      decodedJson.value = null;
      await _lookupByBarcode(rawData.trim());
    } catch (e) {
      if (kDebugMode) debugPrint('[QrScannerCtrl] handleScannedData error: $e');
      errorMessage.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> _lookupByBarcode(String barcode) async {
    if (barcode.isEmpty) {
      errorMessage.value = _tr('invalid_qr_format');
      return;
    }
    try {
      final device = await _getDeviceByBarcode(barcode);
      if (device != null) {
        liveDevice.value = device;
      } else {
        // Try searching by serial number or device name
        final all = await _getDevices();
        final q = barcode.toLowerCase();
        final match = all.firstWhereOrNull(
          (d) =>
              d.serialNumber1.toLowerCase() == q ||
              d.serialNumber2.toLowerCase() == q ||
              d.deviceName.toLowerCase().contains(q),
        );
        if (match != null) {
          liveDevice.value = match;
        } else {
          errorMessage.value = '${_tr('no_device_barcode')}: $barcode';
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[QrScannerCtrl] lookupByBarcode error: $e');
      errorMessage.value = '${_tr('search_failed')}: $e';
    }
  }

  Future<void> _fetchLiveDevice(String deviceId) async {
    try {
      final all = await _getDevices();
      final match = all.firstWhereOrNull((d) => d.id == deviceId);
      liveDevice.value = match;
    } catch (e) {
      if (kDebugMode) debugPrint('[QrScannerCtrl] fetchLiveDevice error: $e');
    }
  }

  void handleTextInput(String text) {
    if (text.trim().isEmpty) return;
    handleScannedData(text.trim());
  }

  void reset() {
    scannedData.value = null;
    decodedJson.value = null;
    liveDevice.value = null;
    errorMessage.value = '';
    scanning.value = false;
  }

  String _tr(String key) {
    final ctx = Get.context;
    if (ctx != null) {
      return AppLocalizations.of(ctx)?.tr(key) ?? key;
    }
    return key;
  }
}
