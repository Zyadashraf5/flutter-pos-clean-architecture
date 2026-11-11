import '../../repositories/product_repository.dart';

class IncreaseStock {
  IncreaseStock(this._repository);

  final ProductRepository _repository;

  Future<void> call(String productId, int quantity, {double? purchasePrice}) =>
      _repository.increaseStock(productId, quantity, purchasePrice: purchasePrice);
}
