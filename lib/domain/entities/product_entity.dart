import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    required this.taxPercent,
    required this.barcode,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.createdByUid,
    this.updatedByUid,
  });

  final String id;
  final String name;
  final String categoryId;
  final double purchasePrice;
  final double sellingPrice;
  final int quantity;
  final double taxPercent;
  final String barcode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? createdByUid;
  final String? updatedByUid;

  @override
  List<Object?> get props =>
      [id, name, categoryId, purchasePrice, sellingPrice, quantity, taxPercent, barcode, createdAt, updatedAt, isActive, createdByUid, updatedByUid];
}
