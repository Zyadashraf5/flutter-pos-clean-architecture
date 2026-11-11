import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAll();
  Future<CategoryEntity?> getById(String id);
  Future<void> create(CategoryEntity entity);
  Future<void> update(CategoryEntity entity);
  Future<void> delete(String id);
}
