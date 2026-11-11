import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getAll();
  Future<List<ProductEntity>> getByCategoryId(String categoryId);
  Future<ProductEntity?> getById(String id);
  Future<ProductEntity?> getByBarcode(String barcode);
  Future<void> create(ProductEntity entity);
  Future<void> update(ProductEntity entity);
  Future<void> delete(String id);
  Future<void> decreaseStock(String productId, int quantity);
  /// Adds [quantity] to product stock. If [purchasePrice] is provided, updates
  /// product's purchase price to weighted average of existing and new.
  Future<void> increaseStock(String productId, int quantity, {double? purchasePrice});
}
