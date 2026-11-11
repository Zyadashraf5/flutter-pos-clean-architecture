import 'package:hive/hive.dart';

import '../../models/order_model.dart';
import 'local_storage.dart';

class OrderLocalDatasource {
  Box<dynamic> get _box => LocalStorage.ordersBox;

  Future<List<OrderModel>> getAll() async {
    final list = <OrderModel>[];
    for (final key in _box.keys) {
      final v = _box.get(key);
      if (v is Map) {
        list.add(OrderModel.fromJson(Map<String, dynamic>.from(v)));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<OrderModel?> getById(String id) async {
    final v = _box.get(id);
    if (v is Map) {
      return OrderModel.fromJson(Map<String, dynamic>.from(v));
    }
    return null;
  }

  Future<void> create(OrderModel model) async {
    await _box.put(model.id, model.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
