import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class UpdateCategory {
  UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call(CategoryEntity entity) => _repository.update(entity);
}
