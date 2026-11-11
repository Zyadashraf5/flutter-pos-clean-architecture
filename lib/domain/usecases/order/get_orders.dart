import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrders {
  GetOrders(this._repository);

  final OrderRepository _repository;

  Future<List<OrderEntity>> call() => _repository.getAll();
}
