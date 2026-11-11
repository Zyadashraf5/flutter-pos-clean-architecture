import 'package:hive/hive.dart';

import '../../models/product_model.dart';
import 'local_storage.dart';

class ProductLocalDatasource {
  Box<dynamic> get _box => LocalStorage.productsBox;

  Future<List<ProductModel>> getAll() async {
    final list = <ProductModel>[];
    for (final key in _box.keys) {
      final v = _box.get(key);
      if (v is Map) {
        list.add(ProductModel.fromJson(Map<String, dynamic>.from(v)));
      }
    }
    return list..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<ProductModel?> getById(String id) async {
    final v = _box.get(id);
    if (v is Map) {
      return ProductModel.fromJson(Map<String, dynamic>.from(v));
    }
    return null;
  }

  Future<ProductModel?> getByBarcode(String barcode) async {
    final all = await getAll();
    try {
      return all.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> getByCategoryId(String categoryId) async {
    final all = await getAll();
    return all.where((p) => p.categoryId == categoryId).toList();
  }

  Future<void> create(ProductModel model) async {
    await _box.put(model.id, model.toJson());
  }

  Future<void> update(ProductModel model) async {
    await _box.put(model.id, model.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
