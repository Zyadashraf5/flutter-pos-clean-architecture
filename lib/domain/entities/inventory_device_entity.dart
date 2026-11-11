import 'package:equatable/equatable.dart';

/// Device condition: used or brand new.
enum DeviceCondition { used, newDevice }

/// How the receiving price was paid.
enum ReceivingPaymentMethod { cash, credit, bankTransfer }

class InventoryDeviceEntity extends Equatable {
  const InventoryDeviceEntity({
    required this.id,
    required this.deviceName,
    required this.barcode,
    required this.serialNumber1,
    required this.serialNumber2,
    required this.condition,
    required this.color,
    required this.storage,
    this.batteryHealth,
    required this.receivingPrice,
    this.sellingPrice,
    required this.paymentMethod,
    required this.supplierName,
    required this.supplierPhone,
    this.categoryId,
    this.isSold = false,
    this.createdAt,
    this.createdByUid,
  });

  final String id;
  final String deviceName;
  final String barcode;
  final String serialNumber1;
  final String serialNumber2;
  final DeviceCondition condition;
  final String color;
  final String storage;
  final String? batteryHealth; // only for used devices
  final double receivingPrice;
  final double? sellingPrice;
  final ReceivingPaymentMethod paymentMethod;
  final String supplierName;
  final String supplierPhone;
  final String? categoryId;
  final bool isSold;
  final DateTime? createdAt;
  final String? createdByUid;

  /// Returns a copy with updated fields.
  InventoryDeviceEntity copyWith({
    String? id,
    String? deviceName,
    String? barcode,
    String? serialNumber1,
    String? serialNumber2,
    DeviceCondition? condition,
    String? color,
    String? storage,
    String? batteryHealth,
    double? receivingPrice,
    double? sellingPrice,
    ReceivingPaymentMethod? paymentMethod,
    String? supplierName,
    String? supplierPhone,
    String? categoryId,
    bool? isSold,
    DateTime? createdAt,
    String? createdByUid,
  }) {
    return InventoryDeviceEntity(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      barcode: barcode ?? this.barcode,
      serialNumber1: serialNumber1 ?? this.serialNumber1,
      serialNumber2: serialNumber2 ?? this.serialNumber2,
      condition: condition ?? this.condition,
      color: color ?? this.color,
      storage: storage ?? this.storage,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      receivingPrice: receivingPrice ?? this.receivingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      supplierName: supplierName ?? this.supplierName,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      categoryId: categoryId ?? this.categoryId,
      isSold: isSold ?? this.isSold,
      createdAt: createdAt ?? this.createdAt,
      createdByUid: createdByUid ?? this.createdByUid,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceName,
    barcode,
    serialNumber1,
    serialNumber2,
    condition,
    color,
    storage,
    batteryHealth,
    receivingPrice,
    sellingPrice,
    paymentMethod,
    supplierName,
    supplierPhone,
    categoryId,
    isSold,
    createdAt,
    createdByUid,
  ];
}
