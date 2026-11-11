import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getAll();
  Future<OrderEntity?> getById(String id);
  Future<void> create(OrderEntity order);
  Future<void> delete(String id);
}
