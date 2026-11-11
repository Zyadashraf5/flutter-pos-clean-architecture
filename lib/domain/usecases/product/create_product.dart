import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class CreateProduct {
  CreateProduct(this._repository);

  final ProductRepository _repository;

  Future<void> call(ProductEntity entity) => _repository.create(entity);
}
