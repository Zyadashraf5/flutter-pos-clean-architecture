import '../../domain/entities/inventory_device_entity.dart';

class InventoryDeviceModel extends InventoryDeviceEntity {
  const InventoryDeviceModel({
    required super.id,
    required super.deviceName,
    required super.barcode,
    required super.serialNumber1,
    required super.serialNumber2,
    required super.condition,
    required super.color,
    required super.storage,
    super.batteryHealth,
    required super.receivingPrice,
    super.sellingPrice,
    required super.paymentMethod,
    required super.supplierName,
    required super.supplierPhone,
    super.categoryId,
    super.isSold,
    super.createdAt,
    super.createdByUid,
  });

  factory InventoryDeviceModel.fromJson(Map<String, dynamic> json) {
    return InventoryDeviceModel(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String? ?? '',
      barcode: json['barcode'] as String,
      serialNumber1: json['serialNumber1'] as String,
      serialNumber2: json['serialNumber2'] as String,
      condition: _conditionFromString(json['condition'] as String? ?? 'used'),
      color: json['color'] as String? ?? '',
      storage: json['storage'] as String? ?? '',
      batteryHealth: json['batteryHealth'] as String?,
      receivingPrice: (json['receivingPrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      paymentMethod: _paymentFromString(
        json['paymentMethod'] as String? ?? 'cash',
      ),
      supplierName: json['supplierName'] as String? ?? '',
      supplierPhone: json['supplierPhone'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      isSold: json['isSold'] as bool? ?? false,
      createdByUid: json['createdByUid'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'barcode': barcode,
    'serialNumber1': serialNumber1,
    'serialNumber2': serialNumber2,
    'condition': condition == DeviceCondition.used ? 'used' : 'new',
    'color': color,
    'storage': storage,
    if (batteryHealth != null) 'batteryHealth': batteryHealth,
    'receivingPrice': receivingPrice,
    if (sellingPrice != null) 'sellingPrice': sellingPrice,
    'paymentMethod': _paymentToString(paymentMethod),
    'supplierName': supplierName,
    'supplierPhone': supplierPhone,
    if (categoryId != null) 'categoryId': categoryId,
    'isSold': isSold,
    if (createdByUid != null) 'createdByUid': createdByUid,
  };

  factory InventoryDeviceModel.fromEntity(InventoryDeviceEntity entity) {
    return InventoryDeviceModel(
      id: entity.id,
      deviceName: entity.deviceName,
      barcode: entity.barcode,
      serialNumber1: entity.serialNumber1,
      serialNumber2: entity.serialNumber2,
      condition: entity.condition,
      color: entity.color,
      storage: entity.storage,
      batteryHealth: entity.batteryHealth,
      receivingPrice: entity.receivingPrice,
      sellingPrice: entity.sellingPrice,
      paymentMethod: entity.paymentMethod,
      supplierName: entity.supplierName,
      supplierPhone: entity.supplierPhone,
      categoryId: entity.categoryId,
      isSold: entity.isSold,
      createdAt: entity.createdAt,
      createdByUid: entity.createdByUid,
    );
  }

  static DeviceCondition _conditionFromString(String value) {
    switch (value) {
      case 'new':
        return DeviceCondition.newDevice;
      default:
        return DeviceCondition.used;
    }
  }

  static ReceivingPaymentMethod _paymentFromString(String value) {
    switch (value) {
      case 'credit':
        return ReceivingPaymentMethod.credit;
      case 'bankTransfer':
        return ReceivingPaymentMethod.bankTransfer;
      default:
        return ReceivingPaymentMethod.cash;
    }
  }

  static String _paymentToString(ReceivingPaymentMethod method) {
    switch (method) {
      case ReceivingPaymentMethod.cash:
        return 'cash';
      case ReceivingPaymentMethod.credit:
        return 'credit';
      case ReceivingPaymentMethod.bankTransfer:
        return 'bankTransfer';
    }
  }
}
