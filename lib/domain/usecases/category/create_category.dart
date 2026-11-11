import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class CreateCategory {
  CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call(CategoryEntity entity) => _repository.create(entity);
}
