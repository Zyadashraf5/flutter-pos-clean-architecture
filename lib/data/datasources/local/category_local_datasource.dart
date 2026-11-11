import 'package:hive/hive.dart';

import '../../models/category_model.dart';
import 'local_storage.dart';

class CategoryLocalDatasource {
  Box<dynamic> get _box => LocalStorage.categoriesBox;

  Future<List<CategoryModel>> getAll() async {
    final list = <CategoryModel>[];
    for (final key in _box.keys) {
      final v = _box.get(key);
      if (v is Map) {
        list.add(CategoryModel.fromJson(Map<String, dynamic>.from(v)));
      }
    }
    return list..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<CategoryModel?> getById(String id) async {
    final v = _box.get(id);
    if (v is Map) {
      return CategoryModel.fromJson(Map<String, dynamic>.from(v));
    }
    return null;
  }

  Future<void> create(CategoryModel model) async {
    await _box.put(model.id, model.toJson());
  }

  Future<void> update(CategoryModel model) async {
    await _box.put(model.id, model.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
