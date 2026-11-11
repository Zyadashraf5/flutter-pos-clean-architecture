import '../../repositories/category_repository.dart';

class DeleteCategory {
  DeleteCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
