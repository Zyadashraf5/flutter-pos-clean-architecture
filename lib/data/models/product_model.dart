import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.purchasePrice,
    required super.sellingPrice,
    required super.quantity,
    required super.taxPercent,
    required super.barcode,
    super.createdByUid,
    super.updatedByUid,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      taxPercent: (json['taxPercent'] as num).toDouble(),
      barcode: json['barcode'] as String? ?? '',
      createdByUid: json['createdByUid'] as String?,
      updatedByUid: json['updatedByUid'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'purchasePrice': purchasePrice,
    'sellingPrice': sellingPrice,
    'quantity': quantity,
    'taxPercent': taxPercent,
    'taxPercentage': taxPercent, // Firestore-native field name
    'barcode': barcode,
    'isActive': true, // Ensure Firestore queries work
    if (createdByUid != null) 'createdByUid': createdByUid,
    if (updatedByUid != null) 'updatedByUid': updatedByUid,
  };

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      purchasePrice: entity.purchasePrice,
      sellingPrice: entity.sellingPrice,
      quantity: entity.quantity,
      taxPercent: entity.taxPercent,
      barcode: entity.barcode,
      createdByUid: entity.createdByUid,
      updatedByUid: entity.updatedByUid,
    );
  }
}
