import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class GetProductByBarcode {
  GetProductByBarcode(this._repository);

  final ProductRepository _repository;

  Future<ProductEntity?> call(String barcode) =>
      _repository.getByBarcode(barcode);
}
