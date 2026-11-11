import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class UpdateProduct {
  UpdateProduct(this._repository);

  final ProductRepository _repository;

  Future<void> call(ProductEntity entity) => _repository.update(entity);
}
