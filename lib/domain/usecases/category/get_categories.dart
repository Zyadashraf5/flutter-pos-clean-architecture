import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class GetCategories {
  GetCategories(this._repository);

  final CategoryRepository _repository;

  Future<List<CategoryEntity>> call() => _repository.getAll();
}
