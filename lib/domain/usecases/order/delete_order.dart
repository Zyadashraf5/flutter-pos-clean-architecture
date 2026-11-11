import '../../repositories/order_repository.dart';

class DeleteOrder {
  DeleteOrder(this._repository);

  final OrderRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
