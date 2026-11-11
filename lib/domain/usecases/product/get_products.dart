import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class GetProducts {
  GetProducts(this._repository);

  final ProductRepository _repository;

  Future<List<ProductEntity>> call({String? categoryId}) {
    if (categoryId != null && categoryId.isNotEmpty) {
      return _repository.getByCategoryId(categoryId);
    }
    return _repository.getAll();
  }
}
